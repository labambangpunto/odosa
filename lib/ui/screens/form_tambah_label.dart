import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/master_data_provider.dart';

class FormTambahLabel extends ConsumerStatefulWidget {
  const FormTambahLabel({super.key});

  @override
  ConsumerState<FormTambahLabel> createState() => _FormTambahLabelState();
}

class _FormTambahLabelState extends ConsumerState<FormTambahLabel> {
  final List<TextEditingController> _controllers = [TextEditingController()];
  final int _maxFields = 7;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged(int index, String value) {
    if (value.isNotEmpty &&
        index == _controllers.length - 1 &&
        _controllers.length < _maxFields) {
      setState(() {
        _controllers.add(TextEditingController());
      });
    }
  }

  void _simpan() {
    // Mengambil nilai teks, menghapus spasi, dan membuang yang kosong
    final labels = _controllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    // Mencegah duplikasi nama label dalam satu kali submit
    final uniqueLabels = labels.toSet().toList();

    if (uniqueLabels.isNotEmpty) {
      ref.read(labelListProvider.notifier).addLabels(uniqueLabels);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Label'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _simpan),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _controllers.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: TextField(
              controller: _controllers[index],
              decoration: InputDecoration(
                labelText: 'Nama label baru ${index + 1}',
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => _onTextChanged(index, value),
            ),
          );
        },
      ),
    );
  }
}
