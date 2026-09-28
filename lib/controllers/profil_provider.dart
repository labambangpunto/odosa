import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilNotifier extends StateNotifier<String> {
  ProfilNotifier() : super('Pengguna') {
    _loadNama();
  }

  Future<void> _loadNama() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('nama_pengguna') ?? 'Pengguna';
  }

  Future<void> simpanNama(String namaBaru) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nama_pengguna', namaBaru);
    state = namaBaru;
  }
}

final profilProvider = StateNotifierProvider<ProfilNotifier, String>((ref) {
  return ProfilNotifier();
});
