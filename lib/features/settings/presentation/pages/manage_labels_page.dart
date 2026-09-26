import 'package:flutter/material.dart';

class ManageLabelsPage extends StatefulWidget {
  const ManageLabelsPage({super.key});

  @override
  State<ManageLabelsPage> createState() => _ManageLabelsPageState();
}

class _ManageLabelsPageState extends State<ManageLabelsPage> {
  final List<String> _labels = [
    'Makan',
    'Transport',
    'Gaji',
    'Bonus',
    'Tagihan',
  ];

  void _showFormDialog({String? initialName, int? index}) {
    final controller = TextEditingController(text: initialName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initialName == null ? 'Tambah Label' : 'Edit Label'),
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
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  if (index == null) {
                    _labels.add(text);
                  } else {
                    _labels[index] = text;
                  }
                });

                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _deleteLabel(int index) {
    setState(() {
      _labels.removeAt(index);
    });
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
      body: ListView.separated(
        itemCount: _labels.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final label = _labels[index];
          return ListTile(
            title: Text(label),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  onPressed: () =>
                      _showFormDialog(initialName: label, index: index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteLabel(index),
                ),
              ],
            ),
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
