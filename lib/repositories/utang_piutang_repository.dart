import '../core/database/database_helper.dart';
import '../models/utang_piutang.dart';

class UtangPiutangRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(UtangPiutang item) async {
    final db = await dbHelper.database;
    return await db.insert('utang_piutang', item.toMap());
  }

  Future<List<UtangPiutang>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'utang_piutang',
      orderBy: 'tanggal_waktu DESC',
    );

    return List.generate(maps.length, (i) {
      return UtangPiutang(
        id: maps[i]['id'] as int,
        tipe: TipeUtangPiutang.values[maps[i]['tipe'] as int],
        nominal: maps[i]['nominal'] as double,
        pihakTerkait: maps[i]['pihak_terkait'] as String,
        idAkun: maps[i]['id_akun'] as int,
        tanggalWaktu: DateTime.parse(maps[i]['tanggal_waktu'] as String),
        tenggatWaktu: DateTime.parse(maps[i]['tenggat_waktu'] as String),
        catatan: maps[i]['catatan'] as String,
        statusLunas: (maps[i]['status_lunas'] as int) == 1,
      );
    });
  }

  Future<int> update(UtangPiutang item) async {
    final db = await dbHelper.database;
    return await db.update(
      'utang_piutang',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete('utang_piutang', where: 'id = ?', whereArgs: [id]);
  }
}
