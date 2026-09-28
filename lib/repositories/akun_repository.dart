import '../core/database/database_helper.dart';
import '../models/akun.dart';

class AkunRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(Akun akun) async {
    final db = await dbHelper.database;
    return await db.insert('akun', akun.toMap());
  }

  Future<List<Akun>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('akun');

    return List.generate(maps.length, (i) {
      return Akun(
        id: maps[i]['id'] as int,
        nama: maps[i]['nama'] as String,
        saldoAwal: maps[i]['saldo_awal'] as double,
      );
    });
  }

  Future<int> update(Akun akun) async {
    final db = await dbHelper.database;
    return await db.update(
      'akun',
      akun.toMap(),
      where: 'id = ?',
      whereArgs: [akun.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete('akun', where: 'id = ?', whereArgs: [id]);
  }
}
