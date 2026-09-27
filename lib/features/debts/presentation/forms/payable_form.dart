import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;

import '../../../transactions/models/transaction_model.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../transactions/presentation/widgets/account_dropdown.dart';
import '../../../transactions/presentation/widgets/label_chip_input.dart';
import '../widgets/contact_picker.dart';

class PayableForm extends StatefulWidget {
  final Debt? debt;
  const PayableForm({super.key, this.debt});

  @override
  State<PayableForm> createState() => _PayableFormState();
}

class _PayableFormState extends State<PayableForm> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _contact = '';
  String? _destinationAccount;
  List<String> _labels = [];
  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;

  bool _isSettled = false;
  String? _settlementAccount;
  DateTime? _settlementDate;

  @override
  void initState() {
    super.initState();
    if (widget.debt != null) {
      final d = widget.debt!;
      final formatter = NumberFormat('#,###', 'en_US');

      _amountController.text = formatter.format(d.amount).replaceAll(',', '.');
      _contact = d.contact;
      _destinationAccount = d.primaryAccount;
      _labels = d.labels?.isNotEmpty == true ? d.labels!.split(',') : [];
      _selectedDate = d.transactionDate;
      _dueDate = d.dueDate;
      _noteController.text = d.note;
      _isSettled = d.isSettled;
      _settlementAccount = d.settlementAccount;
      _settlementDate = d.settlementDate;
    }
  }

  // ... (lanjutkan ke fungsi _submit)

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final db = AppDatabase();
      final amount = double.parse(_amountController.text.replaceAll('.', ''));

      if (widget.debt == null) {
        await db
            .into(db.debts)
            .insert(
              DebtsCompanion.insert(
                type: 'payable',
                amount: amount,
                contact: _contact,
                primaryAccount: _destinationAccount ?? '',
                labels: drift.Value(_labels.join(',')),
                transactionDate: _selectedDate,
                dueDate: drift.Value(_dueDate),
                note: _noteController.text,
                isSettled: drift.Value(_isSettled),
                settlementAccount: drift.Value(_settlementAccount),
                settlementDate: drift.Value(_settlementDate),
              ),
            );
      } else {
        await (db.update(
          db.debts,
        )..where((d) => d.id.equals(widget.debt!.id))).write(
          DebtsCompanion(
            amount: drift.Value(amount),
            contact: drift.Value(_contact),
            primaryAccount: drift.Value(_destinationAccount ?? ''),
            labels: drift.Value(_labels.join(',')),
            transactionDate: drift.Value(_selectedDate),
            dueDate: drift.Value(_dueDate),
            note: drift.Value(_noteController.text),
            isSettled: drift.Value(_isSettled),
            settlementAccount: drift.Value(_settlementAccount),
            settlementDate: drift.Value(_settlementDate),
          ),
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
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
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(),
            ],
            decoration: const InputDecoration(
              labelText: 'Nominal',
              border: OutlineInputBorder(),
              prefixText: 'Rp ',
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 16),
          ContactPicker(
            label: 'Kontak / Pihak Kedua',
            initialValue: _contact.isNotEmpty ? _contact : null,
            onChanged: (val) => _contact = val,
          ),
          const SizedBox(height: 16),
          AccountDropdown(
            label: 'Akun Tujuan (Penerima Dana)',
            value: _destinationAccount,
            onChanged: (val) => setState(() => _destinationAccount = val),
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
            onTap: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                if (!context.mounted) return;
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
            },
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
              final date = await showDatePicker(
                context: context,
                initialDate: _dueDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (date != null) setState(() => _dueDate = date);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _noteController,
            maxLength: 150,
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
                color: Colors.blue.withValues(alpha: 0.05),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
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
                    label: 'Akun Sumber Pelunasan',
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
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _settlementDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
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
            child: Text(widget.debt == null ? 'Simpan Utang' : 'Simpan Update'),
          ),
        ],
      ),
    );
  }
}
