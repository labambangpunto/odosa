import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/akun.dart';
import '../models/label.dart';
import '../repositories/akun_repository.dart';
import '../repositories/label_repository.dart';
import '../models/transaksi.dart';
import '../repositories/transaksi_repository.dart';

final labelRepositoryProvider = Provider((ref) => LabelRepository());
final akunRepositoryProvider = Provider((ref) => AkunRepository());
final transaksiRepositoryProvider = Provider((ref) => TransaksiRepository());

final transaksiListProvider =
    StateNotifierProvider<TransaksiNotifier, List<Transaksi>>((ref) {
      return TransaksiNotifier(ref.watch(transaksiRepositoryProvider));
    });
// State Notifier untuk Label
final labelListProvider =
    StateNotifierProvider<LabelNotifier, List<KategoriLabel>>((ref) {
      return LabelNotifier(ref.watch(labelRepositoryProvider));
    });

class LabelNotifier extends StateNotifier<List<KategoriLabel>> {
  final LabelRepository _repository;
  LabelNotifier(this._repository) : super([]) {
    loadLabels();
  }

  Future<void> loadLabels() async {
    state = await _repository.getAll();
  }

  Future<void> addLabels(List<String> namaLabels) async {
    final existingLabels = state.map((e) => e.nama.toLowerCase()).toSet();

    for (var nama in namaLabels) {
      final cleanNama = nama.trim();
      if (cleanNama.isNotEmpty &&
          !existingLabels.contains(cleanNama.toLowerCase())) {
        await _repository.insert(KategoriLabel(nama: cleanNama));
      }
    }
    await loadLabels();
  }
}

// State Notifier untuk Akun
final akunListProvider = StateNotifierProvider<AkunNotifier, List<Akun>>((ref) {
  return AkunNotifier(ref.watch(akunRepositoryProvider));
});

class AkunNotifier extends StateNotifier<List<Akun>> {
  final AkunRepository _repository;
  AkunNotifier(this._repository) : super([]) {
    loadAkun();
  }

  Future<void> loadAkun() async {
    state = await _repository.getAll();
  }

  Future<void> addAkun(List<Akun> daftarAkun) async {
    final existingAkun = state.map((e) => e.nama.toLowerCase()).toSet();

    for (var akun in daftarAkun) {
      final cleanNama = akun.nama.trim();
      if (cleanNama.isNotEmpty &&
          !existingAkun.contains(cleanNama.toLowerCase())) {
        await _repository.insert(
          Akun(nama: cleanNama, saldoAwal: akun.saldoAwal),
        );
      }
    }
    await loadAkun();
  }
}

class TransaksiNotifier extends StateNotifier<List<Transaksi>> {
  final TransaksiRepository _repository;
  TransaksiNotifier(this._repository) : super([]) {
    loadTransaksi();
  }

  Future<void> loadTransaksi() async {
    state = await _repository.getAll();
  }

  Future<void> addTransaksi(Transaksi transaksi) async {
    await _repository.insert(transaksi);
    await loadTransaksi();
  }

  // Tambahkan fungsi berikut:
  Future<void> updateTransaksi(Transaksi transaksi) async {
    await _repository.update(transaksi);
    await loadTransaksi();
  }

  Future<void> deleteTransaksi(int id) async {
    await _repository.delete(id);
    await loadTransaksi();
  }
}
