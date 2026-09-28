import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../controllers/master_data_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/transaksi.dart';

class FormTransferAntarakun extends ConsumerStatefulWidget {
  final Transaksi? dataEdit;
  const FormTransferAntarakun({super.key, this.dataEdit});

  @override
  ConsumerState<FormTransferAntarakun> createState() =>
      _FormTransferAntarakunState();
}

class _FormTransferAntarakunState extends ConsumerState<FormTransferAntarakun> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nominalController;
  late TextEditingController _biayaTambahanController;
  late TextEditingController _catatanController;

  int? _selectedAkunSumberId;
  int? _selectedAkunTujuanId;
  int? _selectedLabelId;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final data = widget.dataEdit;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    _nominalController = TextEditingController(
      text: data != null ? formatter.format(data.nominal) : '',
    );
    _biayaTambahanController = TextEditingController(
      text: (data != null && data.biayaTambahan > 0)
          ? formatter.format(data.biayaTambahan)
          : '',
    );
    _catatanController = TextEditingController(text: data?.catatan ?? '');

    _selectedAkunSumberId = data?.idAkunSumber;
    _selectedAkunTujuanId = data?.idAkunTujuan;
    _selectedLabelId = data?.idLabel;
    _selectedDate = data?.tanggalWaktu ?? DateTime.now();
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _biayaTambahanController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggalWaktu() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      if (_selectedAkunSumberId == null ||
          _selectedAkunTujuanId == null ||
          _selectedLabelId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun sumber, Akun tujuan, dan Label wajib dipilih'),
          ),
        );
        return;
      }

      if (_selectedAkunSumberId == _selectedAkunTujuanId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun sumber dan tujuan tidak boleh sama'),
          ),
        );
        return;
      }

      final transaksi = Transaksi(
        id: widget.dataEdit?.id,
        tipe: TipeTransaksi.transfer,
        nominal: parseCurrency(_nominalController.text),
        biayaTambahan: _biayaTambahanController.text.isEmpty
            ? 0.0
            : parseCurrency(_biayaTambahanController.text),
        idAkunSumber: _selectedAkunSumberId,
        idAkunTujuan: _selectedAkunTujuanId,
        idLabel: _selectedLabelId,
        tanggalWaktu: _selectedDate,
        catatan: _catatanController.text.trim(),
      );

      if (widget.dataEdit == null) {
        ref.read(transaksiListProvider.notifier).addTransaksi(transaksi);
      } else {
        ref.read(transaksiListProvider.notifier).updateTransaksi(transaksi);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final daftarAkun = ref.watch(akunListProvider);
    final daftarLabel = ref.watch(labelListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Antarakun'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _simpan),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nominalController,
              decoration: const InputDecoration(
                labelText: 'Nominal (Rp) *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _selectedAkunSumberId,
              decoration: const InputDecoration(
                labelText: 'Akun sumber *',
                border: OutlineInputBorder(),
              ),
              items: daftarAkun.map((akun) {
                return DropdownMenuItem(value: akun.id, child: Text(akun.nama));
              }).toList(),
              onChanged: (val) => setState(() => _selectedAkunSumberId = val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _selectedAkunTujuanId,
              decoration: const InputDecoration(
                labelText: 'Akun tujuan *',
                border: OutlineInputBorder(),
              ),
              items: daftarAkun.map((akun) {
                return DropdownMenuItem(value: akun.id, child: Text(akun.nama));
              }).toList(),
              onChanged: (val) => setState(() => _selectedAkunTujuanId = val),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _biayaTambahanController,
              decoration: const InputDecoration(
                labelText: 'Biaya tambahan (opsional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Label / Tag *',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8.0,
              children: daftarLabel.map((label) {
                return ChoiceChip(
                  label: Text(label.nama),
                  selected: _selectedLabelId == label.id,
                  onSelected: (selected) {
                    setState(
                      () => _selectedLabelId = selected ? label.id : null,
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tanggal & Waktu *'),
              subtitle: Text(
                DateFormat('dd MMM yyyy, HH:mm').format(_selectedDate),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pilihTanggalWaktu,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _catatanController,
              decoration: const InputDecoration(
                labelText: 'Catatan / deskripsi (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
