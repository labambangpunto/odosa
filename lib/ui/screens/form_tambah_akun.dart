import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/master_data_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/akun.dart';

class AkunInputGroup {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController saldoController = TextEditingController();

  void dispose() {
    namaController.dispose();
    saldoController.dispose();
  }
}

class FormTambahAkun extends ConsumerStatefulWidget {
  const FormTambahAkun({super.key});

  @override
  ConsumerState<FormTambahAkun> createState() => _FormTambahAkunState();
}

class _FormTambahAkunState extends ConsumerState<FormTambahAkun> {
  final List<AkunInputGroup> _inputGroups = [AkunInputGroup()];
  final int _maxFields = 3;

  @override
  void dispose() {
    for (var group in _inputGroups) {
      group.dispose();
    }
    super.dispose();
  }

  void _onNamaChanged(int index, String value) {
    if (value.isNotEmpty &&
        index == _inputGroups.length - 1 &&
        _inputGroups.length < _maxFields) {
      setState(() {
        _inputGroups.add(AkunInputGroup());
      });
    }
  }

  void _simpan() {
    final List<Akun> daftarAkunBaru = [];

    for (var group in _inputGroups) {
      final nama = group.namaController.text.trim();
      final saldoTeks = group.saldoController.text.trim();

      if (nama.isNotEmpty) {
        final saldo = parseCurrency(saldoTeks);
        daftarAkunBaru.add(Akun(nama: nama, saldoAwal: saldo));
      }
    }

    if (daftarAkunBaru.isNotEmpty) {
      ref.read(akunListProvider.notifier).addAkun(daftarAkunBaru);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Akun'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _simpan),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _inputGroups.length,
        itemBuilder: (context, index) {
          final group = _inputGroups[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Akun ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: group.namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama akun baru',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _onNamaChanged(index, value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: group.saldoController,
                    decoration: const InputDecoration(
                      labelText: 'Saldo awal',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CurrencyInputFormatter(),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
