import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../controllers/master_data_provider.dart';
import '../../controllers/utang_piutang_provider.dart';
import '../../models/utang_piutang.dart';

class DialogPelunasan extends ConsumerStatefulWidget {
  final UtangPiutang data;
  const DialogPelunasan({super.key, required this.data});

  @override
  ConsumerState<DialogPelunasan> createState() => _DialogPelunasanState();
}

class _DialogPelunasanState extends ConsumerState<DialogPelunasan> {
  int? _selectedAkunId;
  DateTime _tanggalWaktu = DateTime.now();

  Future<void> _pilihTanggalWaktu() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _tanggalWaktu,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_tanggalWaktu),
      );

      if (time != null) {
        setState(() {
          _tanggalWaktu = DateTime(
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

  void _prosesPelunasan() {
    if (_selectedAkunId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Akun wajib dipilih')));
      return;
    }

    // Mengubah status menjadi lunas
    final utangPiutangLunas = UtangPiutang(
      id: widget.data.id,
      tipe: widget.data.tipe,
      nominal: widget.data.nominal,
      pihakTerkait: widget.data.pihakTerkait,
      idAkun: widget.data.idAkun,
      tanggalWaktu: widget.data.tanggalWaktu,
      tenggatWaktu: widget.data.tenggatWaktu,
      catatan: widget.data.catatan,
      statusLunas: true,
    );

    ref.read(utangPiutangListProvider.notifier).updateData(utangPiutangLunas);

    // Catatan: Logika penambahan transaksi pengeluaran/pemasukan otomatis dapat ditambahkan di sini.
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final daftarAkun = ref.watch(akunListProvider);
    final isUtang = widget.data.tipe == TipeUtangPiutang.utang;
    final labelAkun = isUtang ? 'Akun untuk membayar' : 'Akun untuk menerima';

    return AlertDialog(
      title: Text('Pelunasan ${isUtang ? 'Utang' : 'Piutang'}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            initialValue: _selectedAkunId,
            decoration: InputDecoration(
              labelText: labelAkun,
              border: const OutlineInputBorder(),
            ),
            items: daftarAkun.map((akun) {
              return DropdownMenuItem(value: akun.id, child: Text(akun.nama));
            }).toList(),
            onChanged: (val) => setState(() => _selectedAkunId = val),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tanggal & Waktu'),
            subtitle: Text(
              DateFormat('dd MMM yyyy, HH:mm').format(_tanggalWaktu),
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pilihTanggalWaktu,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(onPressed: _prosesPelunasan, child: const Text('Lunas')),
      ],
    );
  }
}
