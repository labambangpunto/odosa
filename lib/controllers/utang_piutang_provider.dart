import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/utang_piutang.dart';
import '../repositories/utang_piutang_repository.dart';

final utangPiutangRepositoryProvider = Provider(
  (ref) => UtangPiutangRepository(),
);

class UtangPiutangNotifier extends StateNotifier<List<UtangPiutang>> {
  final UtangPiutangRepository _repository;
  UtangPiutangNotifier(this._repository) : super([]) {
    loadData();
  }

  Future<void> loadData() async {
    state = await _repository.getAll();
  }

  Future<void> addData(UtangPiutang item) async {
    await _repository.insert(item);
    await loadData();
  }

  Future<void> updateData(UtangPiutang item) async {
    await _repository.update(item);
    await loadData();
  }

  Future<void> deleteData(int id) async {
    await _repository.delete(id);
    await loadData();
  }
}

final utangPiutangListProvider =
    StateNotifierProvider<UtangPiutangNotifier, List<UtangPiutang>>((ref) {
      return UtangPiutangNotifier(ref.watch(utangPiutangRepositoryProvider));
    });
