import 'package:flutter/material.dart';

class ContactPicker extends StatelessWidget {
  final String label;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;

  const ContactPicker({
    super.key,
    required this.label,
    this.initialValue,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    // Data dummy, nantinya bisa ditarik dari database kontak
    final List<String> dummyContacts = ['Budi', 'Siti', 'Agus', 'Kantor'];

    return Autocomplete<String>(
      initialValue: initialValue != null
          ? TextEditingValue(text: initialValue!)
          : null,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return dummyContacts.where((String option) {
          return option.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      onSelected: (String selection) => onChanged(selection),
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
                hintText: 'Pilih atau ketik nama kontak',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: onChanged,
              validator:
                  validator ??
                  (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
            );
          },
    );
  }
}
