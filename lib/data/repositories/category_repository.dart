import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../../main.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoryRepository(db);
});

class CategoryRepository {
  final AppDatabase _db;

  CategoryRepository(this._db);

  Stream<List<Category>> watchAllCategories() {
    return _db.select(_db.categories).watch();
  }

  Future<int> addCategory(String name, String type) {
    return _db
        .into(_db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: name,
            type: type, // 'IN', 'OUT', atau 'TRANSFER'
          ),
        );
  }
}
