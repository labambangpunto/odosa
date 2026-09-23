import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../data/database/database.dart';

class ExportService {
  final AppDatabase _db;

  ExportService(this._db);

  Future<String> exportTransactionsToCSV() async {
    // Mengambil seluruh data transaksi
    final transactions = await _db.select(_db.transactions).get();

    if (transactions.isEmpty) {
      throw Exception('Tidak ada data transaksi untuk diekspor.');
    }

    // Membuat header CSV
    List<List<dynamic>> rows = [
      [
        'ID',
        'Tipe',
        'Jumlah',
        'Dari_Akun_ID',
        'Ke_Akun_ID',
        'Kategori_ID',
        'Tanggal',
        'Catatan',
      ],
    ];

    // Memasukkan data transaksi
    for (var t in transactions) {
      rows.add([
        t.id,
        t.type,
        t.amount,
        t.fromAccountId ?? '',
        t.toAccountId ?? '',
        t.categoryId ?? '',
        t.date.toIso8601String(),
        t.note ?? '',
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    // Menyimpan file CSV ke direktori dokumen aplikasi
    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'laporan_transaksi_${DateTime.now().millisecondsSinceEpoch}.csv';
    final filePath = p.join(directory.path, fileName);
    final file = File(filePath);

    await file.writeAsString(csvData);

    return filePath;
  }
}
