import '../core/database/database_helper.dart';
import '../models/label.dart';

class LabelRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(KategoriLabel label) async {
    final db = await dbHelper.database;
    return await db.insert('label', label.toMap());
  }

  Future<List<KategoriLabel>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('label');

    return List.generate(maps.length, (i) {
      return KategoriLabel(
        id: maps[i]['id'] as int,
        nama: maps[i]['nama'] as String,
      );
    });
  }

  Future<int> update(KategoriLabel label) async {
    final db = await dbHelper.database;
    return await db.update(
      'label',
      label.toMap(),
      where: 'id = ?',
      whereArgs: [label.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete('label', where: 'id = ?', whereArgs: [id]);
  }
}
