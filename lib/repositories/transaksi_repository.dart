import '../core/database/database_helper.dart';
import '../models/transaksi.dart';

class TransaksiRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(Transaksi transaksi) async {
    final db = await dbHelper.database;
    return await db.insert('transaksi', transaksi.toMap());
  }

  Future<List<Transaksi>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transaksi',
      orderBy: 'tanggal_waktu DESC',
    );

    return List.generate(maps.length, (i) {
      return Transaksi(
        id: maps[i]['id'] as int,
        tipe: TipeTransaksi.values[maps[i]['tipe'] as int],
        nominal: maps[i]['nominal'] as double,
        biayaTambahan: maps[i]['biaya_tambahan'] as double,
        kuantitas: maps[i]['kuantitas'] as int,
        idAkunSumber: maps[i]['id_akun_sumber'] as int?,
        idAkunTujuan: maps[i]['id_akun_tujuan'] as int?,
        idLabel: maps[i]['id_label'] as int?,
        tanggalWaktu: DateTime.parse(maps[i]['tanggal_waktu'] as String),
        catatan: maps[i]['catatan'] as String,
      );
    });
  }

  Future<int> update(Transaksi transaksi) async {
    final db = await dbHelper.database;
    return await db.update(
      'transaksi',
      transaksi.toMap(),
      where: 'id = ?',
      whereArgs: [transaksi.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete('transaksi', where: 'id = ?', whereArgs: [id]);
  }
}
