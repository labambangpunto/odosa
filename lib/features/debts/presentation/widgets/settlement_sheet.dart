import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../transactions/presentation/widgets/account_dropdown.dart';

class SettlementSheet extends StatefulWidget {
  final String debtType; // 'payable' atau 'receivable'
  final double amount;
  final VoidCallback onSuccess;

  const SettlementSheet({
    super.key,
    required this.debtType,
    required this.amount,
    required this.onSuccess,
  });

  static void show(
    BuildContext context, {
    required String debtType,
    required double amount,
    required VoidCallback onSuccess,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SettlementSheet(
        debtType: debtType,
        amount: amount,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<SettlementSheet> createState() => _SettlementSheetState();
}

class _SettlementSheetState extends State<SettlementSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _settlementAccount;
  DateTime _settlementDate = DateTime.now();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSuccess();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPayable = widget.debtType == 'payable';
    final accountLabel = isPayable
        ? 'Akun Sumber Pelunasan'
        : 'Akun Penerima Pelunasan';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pelunasan ${isPayable ? 'Utang' : 'Piutang'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Nominal: Rp ${NumberFormat('#,###').format(widget.amount)}'),
            const SizedBox(height: 24),
            AccountDropdown(
              label: accountLabel,
              value: _settlementAccount,
              onChanged: (val) => setState(() => _settlementAccount = val),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              title: const Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Text('Tanggal Pelunasan'),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(DateFormat('dd MMM yyyy').format(_settlementDate)),
              ),
              trailing: const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _settlementDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (date != null) setState(() => _settlementDate = date);
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _submit,
                child: const Text('Konfirmasi Lunas'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
