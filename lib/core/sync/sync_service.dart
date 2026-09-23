import 'dart:io';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:googleapis/drive/v3.dart' as drive;

import 'google_auth_service.dart';

class SyncService {
  final _secureStorage = const FlutterSecureStorage();

  Future<enc.Key> _getEncryptionKey() async {
    String? base64Key = await _secureStorage.read(key: 'e2ee_key');
    if (base64Key == null) {
      final key = enc.Key.fromSecureRandom(32);
      await _secureStorage.write(key: 'e2ee_key', value: key.base64);
      return key;
    }
    return enc.Key.fromBase64(base64Key);
  }

  Future<File> _encryptDatabase() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'finance_app.sqlite'));

    if (!await dbFile.exists()) {
      throw Exception('File database tidak ditemukan.');
    }

    final bytes = await dbFile.readAsBytes();
    final key = await _getEncryptionKey();
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key));

    final encrypted = encrypter.encryptBytes(bytes, iv: iv);
    final encryptedData = iv.bytes + encrypted.bytes;

    final encryptedFile = File(
      p.join(dbFolder.path, 'finance_app_encrypted.enc'),
    );
    await encryptedFile.writeAsBytes(encryptedData);

    return encryptedFile;
  }

  Future<void> syncDatabaseToGoogleDrive() async {
    final authService = GoogleAuthService();
    final client = await authService.getAuthClient();
    final driveApi = drive.DriveApi(client);

    final encryptedFile = await _encryptDatabase();
    final media = drive.Media(
      encryptedFile.openRead(),
      encryptedFile.lengthSync(),
    );
    const fileName = 'finance_app_backup.enc';

    try {
      // Cari file yang sudah ada di folder aplikasi tersembunyi
      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name='$fileName'",
      );

      final driveFile = drive.File()..name = fileName;

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        // Timpa (update) file yang sudah ada
        final fileId = fileList.files!.first.id!;
        await driveApi.files.update(driveFile, fileId, uploadMedia: media);
      } else {
        // Buat file baru jika belum ada
        driveFile.parents = ['appDataFolder'];
        await driveApi.files.create(driveFile, uploadMedia: media);
      }
    } finally {
      client.close();
    }
  }
}
