import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;

import '../../../transactions/models/transaction_model.dart';

class ManageLabelsPage extends StatefulWidget {
  const ManageLabelsPage({super.key});

  @override
  State<ManageLabelsPage> createState() => _ManageLabelsPageState();
}

class _ManageLabelsPageState extends State<ManageLabelsPage> {
  late final AppDatabase _db;

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
  }

  void _showFormDialog({Label? label}) {
    final controller = TextEditingController(text: label?.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label == null ? 'Tambah Label' : 'Edit Label'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nama Label'),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Menggunakan variabel controller bawaan dialog label
              final name = controller.text.trim();

              if (name.isNotEmpty) {
                // Cek duplikasi nama label
                final existing = await (_db.select(
                  _db.labels,
                )..where((l) => l.name.equals(name))).getSingleOrNull();
                if (existing != null &&
                    (label == null || existing.id != label.id)) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nama label sudah digunakan!'),
                      ),
                    );
                  }
                  return;
                }

                if (label == null) {
                  await _db
                      .into(_db.labels)
                      .insert(LabelsCompanion.insert(name: name));
                } else {
                  await (_db.update(_db.labels)
                        ..where((l) => l.id.equals(label.id)))
                      .write(LabelsCompanion(name: drift.Value(name)));
                }
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _deleteLabel(int id) async {
    await (_db.delete(_db.labels)..where((l) => l.id.equals(id))).go();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Label'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<List<Label>>(
        stream: _db.select(_db.labels).watch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final labels = snapshot.data ?? [];

          if (labels.isEmpty) {
            return const Center(child: Text('Belum ada label terdaftar.'));
          }

          return ListView.separated(
            itemCount: labels.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final label = labels[index];
              return ListTile(
                title: Text(label.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () => _showFormDialog(label: label),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteLabel(label.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
