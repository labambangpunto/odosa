import 'package:flutter/material.dart';

import '../../models/transaction_model.dart';

class LabelChipInput extends StatefulWidget {
  final List<String> selectedLabels;
  final ValueChanged<List<String>> onChanged;
  final String? Function(List<String>?)? validator;

  const LabelChipInput({
    super.key,
    required this.selectedLabels,
    required this.onChanged,
    this.validator,
  });

  @override
  State<LabelChipInput> createState() => _LabelChipInputState();
}

class _LabelChipInputState extends State<LabelChipInput> {
  late Future<List<String>> _labelsFuture;

  @override
  void initState() {
    super.initState();
    _labelsFuture = _getLabelsFromDb();
  }

  Future<List<String>> _getLabelsFromDb() async {
    final db = AppDatabase();
    final labels = await db.select(db.labels).get();
    return labels.map((l) => l.name).toList();
  }

  Future<String?> _showAddLabelDialog() async {
    final controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Label Baru'),
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
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final db = AppDatabase();
                final existing = await (db.select(
                  db.labels,
                )..where((l) => l.name.equals(name))).getSingleOrNull();

                if (existing != null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nama label sudah digunakan!'),
                      ),
                    );
                  }
                  return;
                }

                await db
                    .into(db.labels)
                    .insert(LabelsCompanion.insert(name: name));
                if (context.mounted) Navigator.pop(context, name);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _toggleLabel(
    String label,
    bool isSelected,
    FormFieldState<List<String>> state,
  ) {
    final newList = List<String>.from(widget.selectedLabels);
    if (isSelected) {
      newList.add(label);
    } else {
      newList.remove(label);
    }
    widget.onChanged(newList);
    state.didChange(newList);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<List<String>>(
      initialValue: widget.selectedLabels,
      validator: widget.validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Label / Tag',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<String>>(
              future: _labelsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final availableLabels = snapshot.data ?? [];

                return Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...availableLabels.map((label) {
                      final isSelected = widget.selectedLabels.contains(label);
                      return FilterChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          _toggleLabel(label, selected, state);
                        },
                      );
                    }),
                    // Chip untuk menambah label baru
                    ActionChip(
                      avatar: const Icon(
                        Icons.add,
                        size: 18,
                        color: Colors.blue,
                      ),
                      label: const Text(
                        'Buat label',
                        style: TextStyle(color: Colors.blue),
                      ),
                      backgroundColor: Colors.blue.withValues(alpha: 0.1),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onPressed: () async {
                        final newLabel = await _showAddLabelDialog();
                        if (newLabel != null) {
                          setState(() {
                            _labelsFuture = _getLabelsFromDb();
                          });
                          _toggleLabel(newLabel, true, state);
                        }
                      },
                    ),
                  ],
                );
              },
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  state.errorText!,
                  style: TextStyle(color: Colors.red[700], fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
