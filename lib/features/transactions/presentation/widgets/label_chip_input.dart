import 'package:flutter/material.dart';

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
  Future<List<String>> _getLabelsFromDb() async {
    await Future.delayed(
      const Duration(milliseconds: 100),
    ); // Simulasi delay DB
    return ['Makan', 'Transport', 'Gaji', 'Bonus', 'Tagihan'];
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
              future: _getLabelsFromDb(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final availableLabels = snapshot.data ?? [];

                return Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: availableLabels.map((label) {
                    final isSelected = widget.selectedLabels.contains(label);
                    return FilterChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        _toggleLabel(label, selected, state);
                      },
                    );
                  }).toList(),
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
