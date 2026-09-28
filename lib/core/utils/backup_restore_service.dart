import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

import '../database/database_helper.dart';
import 'encryption_service.dart';

class BackupRestoreService {
  static final dbHelper = DatabaseHelper.instance;

  static Future<String?> exportCSV() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transaksi',
      orderBy: 'tanggal_waktu DESC',
    );

    List<List<dynamic>> rows = [];
    rows.add([
      'ID',
      'Tipe',
      'Nominal',
      'Biaya Tambahan',
      'Kuantitas',
      'ID Akun Sumber',
      'ID Akun Tujuan',
      'ID Label',
      'Tanggal Waktu',
      'Catatan',
    ]);

    for (var row in maps) {
      rows.add([
        row['id'],
        row['tipe'],
        row['nominal'],
        row['biaya_tambahan'],
        row['kuantitas'],
        row['id_akun_sumber'],
        row['id_akun_tujuan'],
        row['id_label'],
        row['tanggal_waktu'],
        row['catatan'],
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    return await _saveFile(csvData, 'transaksi_export.csv');
  }

  static Future<String?> backupJSON(String passphrase) async {
    final db = await dbHelper.database;
    final akun = await db.query('akun');
    final label = await db.query('label');
    final transaksi = await db.query('transaksi');
    final utangPiutang = await db.query('utang_piutang');

    final backupData = {
      'akun': akun,
      'label': label,
      'transaksi': transaksi,
      'utang_piutang': utangPiutang,
    };

    String plainJson = jsonEncode(backupData);
    String encryptedData = EncryptionService.encryptData(plainJson, passphrase);

    // Disimpan dengan ekstensi .enc sebagai penanda file terenkripsi
    return await _saveFile(encryptedData, 'backup_keuangan.enc');
  }

  static Future<bool> restoreJSON(String passphrase) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType
          .any, // Mengizinkan ekstensi bebas karena ekstensi .enc bukan standar native
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String encryptedData = await file.readAsString();

      try {
        String decryptedJson = EncryptionService.decryptData(
          encryptedData,
          passphrase,
        );
        Map<String, dynamic> data = jsonDecode(decryptedJson);

        final db = await dbHelper.database;
        await db.transaction((txn) async {
          await txn.delete('transaksi');
          await txn.delete('utang_piutang');
          await txn.delete('akun');
          await txn.delete('label');

          for (var item in data['akun'] ?? []) {
            await txn.insert('akun', item);
          }
          for (var item in data['label'] ?? []) {
            await txn.insert('label', item);
          }
          for (var item in data['transaksi'] ?? []) {
            await txn.insert('transaksi', item);
          }
          for (var item in data['utang_piutang'] ?? []) {
            await txn.insert('utang_piutang', item);
          }
        });
        return true;
      } catch (e) {
        // Dekripsi gagal jika passphrase salah atau file bukan format enkripsi yang sesuai
        return false;
      }
    }
    return false;
  }

  static Future<String?> _saveFile(String data, String defaultName) async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan File',
      fileName: defaultName,
    );

    if (outputFile != null) {
      File file = File(outputFile);
      await file.writeAsString(data);
      return outputFile;
    }
    return null;
  }

  static Future<String> getEncryptedBackupForSync(String password) async {
    final db = await dbHelper.database;
    final akun = await db.query('akun');
    final label = await db.query('label');
    final transaksi = await db.query('transaksi');
    final utangPiutang = await db.query('utang_piutang');

    final backupData = {
      'akun': akun,
      'label': label,
      'transaksi': transaksi,
      'utang_piutang': utangPiutang,
    };

    String jsonData = jsonEncode(backupData);
    return EncryptionService.encryptData(jsonData, password);
  }

  static Future<bool> restoreFromEncryptedSync(
    String encryptedData,
    String password,
  ) async {
    try {
      String jsonData = EncryptionService.decryptData(encryptedData, password);
      Map<String, dynamic> data = jsonDecode(jsonData);

      final db = await dbHelper.database;
      await db.transaction((txn) async {
        await txn.delete('transaksi');
        await txn.delete('utang_piutang');
        await txn.delete('akun');
        await txn.delete('label');

        for (var item in data['akun'] ?? []) {
          await txn.insert('akun', item);
        }
        for (var item in data['label'] ?? []) {
          await txn.insert('label', item);
        }
        for (var item in data['transaksi'] ?? []) {
          await txn.insert('transaksi', item);
        }
        for (var item in data['utang_piutang'] ?? []) {
          await txn.insert('utang_piutang', item);
        }
      });
      return true;
    } catch (e) {
      // Akan gagal jika password salah atau data korup
      return false;
    }
  }
}
