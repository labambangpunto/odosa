import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../controllers/master_data_provider.dart';
import '../../controllers/utang_piutang_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/utang_piutang.dart';

class FormPembuatanPiutang extends ConsumerStatefulWidget {
  final UtangPiutang? dataEdit;
  const FormPembuatanPiutang({super.key, this.dataEdit});

  @override
  ConsumerState<FormPembuatanPiutang> createState() =>
      _FormPembuatanPiutangState();
}

class _FormPembuatanPiutangState extends ConsumerState<FormPembuatanPiutang> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nominalController;
  late TextEditingController _pihakController;
  late TextEditingController _catatanController;

  int? _selectedAkunId;
  late DateTime _tanggalWaktu;
  late DateTime _tenggatWaktu;

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
    _pihakController = TextEditingController(text: data?.pihakTerkait ?? '');
    _catatanController = TextEditingController(text: data?.catatan ?? '');

    _selectedAkunId = data?.idAkun;
    _tanggalWaktu = data?.tanggalWaktu ?? DateTime.now();
    _tenggatWaktu =
        data?.tenggatWaktu ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _pihakController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggalWaktu(bool isTenggat) async {
    final currentVal = isTenggat ? _tenggatWaktu : _tanggalWaktu;
    final date = await showDatePicker(
      context: context,
      initialDate: currentVal,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentVal),
      );

      if (time != null) {
        setState(() {
          final newDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          if (isTenggat) {
            _tenggatWaktu = newDateTime;
          } else {
            _tanggalWaktu = newDateTime;
          }
        });
      }
    }
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      if (_selectedAkunId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun untuk menerima wajib dipilih')),
        );
        return;
      }

      final utang = UtangPiutang(
        id: widget.dataEdit?.id,
        tipe: TipeUtangPiutang.utang,
        nominal: parseCurrency(_nominalController.text),
        pihakTerkait: _pihakController.text.trim(),
        idAkun: _selectedAkunId!,
        tanggalWaktu: _tanggalWaktu,
        tenggatWaktu: _tenggatWaktu,
        catatan: _catatanController.text.trim(),
        statusLunas: widget.dataEdit?.statusLunas ?? false,
      );

      if (widget.dataEdit == null) {
        ref.read(utangPiutangListProvider.notifier).addData(utang);
      } else {
        ref.read(utangPiutangListProvider.notifier).updateData(utang);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final daftarAkun = ref.watch(akunListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Piutang Baru'),
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
            TextFormField(
              controller: _pihakController,
              decoration: const InputDecoration(
                labelText: 'Pihak penerima dana *',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _selectedAkunId,
              decoration: const InputDecoration(
                labelText: 'Akun untuk memberi *',
                border: OutlineInputBorder(),
              ),
              items: daftarAkun.map((akun) {
                return DropdownMenuItem(value: akun.id, child: Text(akun.nama));
              }).toList(),
              onChanged: (val) => setState(() => _selectedAkunId = val),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tanggal & Waktu *'),
              subtitle: Text(
                DateFormat('dd MMM yyyy, HH:mm').format(_tanggalWaktu),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pilihTanggalWaktu(false),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tanggal Tenggat Waktu *'),
              subtitle: Text(
                DateFormat('dd MMM yyyy, HH:mm').format(_tenggatWaktu),
              ),
              trailing: const Icon(Icons.event_busy),
              onTap: () => _pilihTanggalWaktu(true),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _catatanController,
              decoration: const InputDecoration(
                labelText: 'Catatan / deskripsi *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
            ),
          ],
        ),
      ),
    );
  }
}
