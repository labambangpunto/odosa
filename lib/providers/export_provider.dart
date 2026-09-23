import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/sync/export_service.dart';
import '../../main.dart'; // Menyesuaikan lokasi databaseProvider

final exportServiceProvider = Provider<ExportService>((ref) {
  final db = ref.watch(databaseProvider);
  return ExportService(db);
});
