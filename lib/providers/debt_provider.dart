import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/database.dart';
import '../data/repositories/debt_repository.dart';

final debtsStreamProvider = StreamProvider<List<Debt>>((ref) {
  final repository = ref.watch(debtRepositoryProvider);
  // Menampilkan semua daftar utang/piutang (baik yang lunas maupun belum)
  return repository.watchAllDebts();
});
