import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/contact_picker.dart';
import '../../../transactions/presentation/widgets/account_dropdown.dart';
import '../../../transactions/presentation/widgets/label_chip_input.dart';

class ReceivableForm extends StatefulWidget {
  const ReceivableForm({super.key});

  @override
  State<ReceivableForm> createState() => _ReceivableFormState();
}

class _ReceivableFormState extends State<ReceivableForm> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _contact = '';
  String? _sourceAccount;
  List<String> _labels = [];
  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;

  bool _isSettled = false;
  String? _settlementAccount;
  DateTime? _settlementDate;

  Future<DateTime?> _pickDate(
    BuildContext context, {
    DateTime? initialDate,
  }) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await _pickDate(
      context,
      initialDate: _selectedDate,
    );
    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Variabel _contact digunakan di sini
      debugPrint('Simpan Piutang: ${_amountController.text} untuk $_contact');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Nominal',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 16),
          ContactPicker(
            label: 'Kontak / Pihak Kedua',
            onChanged: (val) => _contact = val,
          ),
          const SizedBox(height: 16),
          AccountDropdown(
            label: 'Akun Sumber (Dana Dipinjamkan)',
            value: _sourceAccount,
            onChanged: (val) => setState(() => _sourceAccount = val),
          ),
          const SizedBox(height: 16),
          LabelChipInput(
            selectedLabels: _labels,
            onChanged: (val) => setState(() => _labels = val),
          ),
          const SizedBox(height: 16),
          ListTile(
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(4.0),
            ),
            title: const Text('Tanggal & Waktu'),
            subtitle: Text(
              DateFormat('dd MMM yyyy, HH:mm').format(_selectedDate),
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _selectDateTime,
          ),
          const SizedBox(height: 16),
          ListTile(
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(4.0),
            ),
            title: const Text('Tenggat Waktu (Opsional)'),
            subtitle: Text(
              _dueDate != null
                  ? DateFormat('dd MMM yyyy').format(_dueDate!)
                  : 'Pilih Tanggal',
            ),
            trailing: _dueDate != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _dueDate = null),
                  )
                : const Icon(Icons.event),
            onTap: () async {
              final date = await _pickDate(context, initialDate: _dueDate);
              if (date != null) setState(() => _dueDate = date);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Catatan/Deskripsi',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Status: Lunas'),
            value: _isSettled,
            onChanged: (val) {
              setState(() {
                _isSettled = val;
                if (val && _settlementDate == null) {
                  _settlementDate = DateTime.now();
                }
              });
            },
          ),
          if (_isSettled) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.05),
                border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Pelunasan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  AccountDropdown(
                    label: 'Akun Penerima Pelunasan',
                    value: _settlementAccount,
                    onChanged: (val) =>
                        setState(() => _settlementAccount = val),
                    validator: (val) =>
                        _isSettled && (val == null || val.isEmpty)
                        ? 'Wajib dipilih'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Tanggal Pelunasan'),
                    subtitle: Text(
                      DateFormat('dd MMM yyyy')
                          .format(_settlementDate ?? DateTime.now()),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await _pickDate(
                        context,
                        initialDate: _settlementDate,
                      );
                      if (date != null) setState(() => _settlementDate = date);
                    },
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Simpan Piutang'),
          ),
        ],
      ),
    );
  }
}
