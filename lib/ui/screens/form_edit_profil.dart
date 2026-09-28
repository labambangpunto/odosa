import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/profil_provider.dart';

class FormEditProfil extends ConsumerStatefulWidget {
  const FormEditProfil({super.key});

  @override
  ConsumerState<FormEditProfil> createState() => _FormEditProfilState();
}

class _FormEditProfilState extends ConsumerState<FormEditProfil> {
  final _namaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Memuat nama yang sedang aktif saat form dibuka
    _namaController.text = ref.read(profilProvider);
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  void _simpan() {
    final nama = _namaController.text.trim();
    if (nama.isNotEmpty) {
      ref.read(profilProvider.notifier).simpanNama(nama);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _simpan),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _namaController,
          decoration: const InputDecoration(
            labelText: 'Nama Panggilan',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
