import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;

import '../../../transactions/presentation/widgets/label_chip_input.dart';
import '../../../transactions/presentation/widgets/label_chip_input.dart';
import '../../../transactions/models/transaction_model.dart';
import '../../../../core/utils/currency_formatter.dart';

class ReceivableForm extends StatefulWidget {
  final Debt? debt;
  const ReceivableForm({super.key, this.debt});

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

  @override
  void initState() {
    super.initState();
    if (widget.debt != null) {
      final d = widget.debt!;
      final formatter = NumberFormat('#,###', 'en_US');

      _amountController.text = formatter.format(d.amount).replaceAll(',', '.');
      _contact = d.contact;
      _sourceAccount = d.primaryAccount;
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

      final currentBalance = await db.getCalculatedBalance(_sourceAccount!);
      final oldAmount = widget.debt != null ? widget.debt!.amount : 0.0;
      final availableBalance = currentBalance + oldAmount;

      if (availableBalance < amount) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Saldo akun tidak mencukupi untuk dipinjamkan!'),
            ),
          );
        }
        return;
      }

      if (widget.debt == null) {
        await db
            .into(db.debts)
            .insert(
              DebtsCompanion.insert(
                type: 'receivable',
                amount: amount,
                contact: _contact,
                primaryAccount: _sourceAccount ?? '',
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
            primaryAccount: drift.Value(_sourceAccount ?? ''),
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
          // ... (Widget fields sama seperti sebelumnya)

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            child: Text(
              widget.debt == null ? 'Simpan Piutang' : 'Simpan Update',
            ),
          ),
        ],
      ),
    );
  }
}
