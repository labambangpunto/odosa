import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../controllers/utang_piutang_provider.dart';
import '../../models/utang_piutang.dart';
import '../widgets/dialog_pelunasan.dart';
import '../../controllers/filter_utang_provider.dart';
import 'form_pembuatan_utang.dart';
import 'form_pembuatan_piutang.dart';

class TabUtang extends ConsumerStatefulWidget {
  const TabUtang({super.key});

  @override
  ConsumerState<TabUtang> createState() => _TabUtangState();
}

class _TabUtangState extends ConsumerState<TabUtang> {
  TipeUtangPiutang _tipeAktif = TipeUtangPiutang.utang;

  void _tampilkanPilihanForm() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.money_off, color: Colors.red),
                title: const Text('Buat Utang'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FormPembuatanUtang(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_money, color: Colors.green),
                title: const Text('Buat Piutang'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FormPembuatanPiutang(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _aksiLongPress(UtangPiutang item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Aksi ${item.tipe == TipeUtangPiutang.utang ? 'Utang' : 'Piutang'}',
          ),
          content: const Text('Pilih aksi untuk data ini.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Widget formWidget = item.tipe == TipeUtangPiutang.utang
                    ? FormPembuatanUtang(dataEdit: item)
                    : FormPembuatanPiutang(dataEdit: item);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => formWidget),
                );
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(utangPiutangListProvider.notifier)
                    .deleteData(item.id!);
                Navigator.pop(context);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _jumpToMonth(BuildContext context, WidgetRef ref) async {
    final filterAktif = ref.read(filterUtangProvider);
    // showDatePicker default tidak bisa hanya pilih bulan.
    // Pendekatan ini menggunakan tanggal 1 sebagai representasi bulan.
    final date = await showDatePicker(
      context: context,
      initialDate: filterAktif.bulanSpesifik,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      ref.read(filterUtangProvider.notifier).state = filterAktif.copyWith(
        bulanSpesifik: DateTime(date.year, date.month),
        clearRentangWaktu: true,
      );
    }
  }

  // Ubah metode build untuk membaca hasil filter:
  @override
  Widget build(BuildContext context) {
    final seluruhData = ref.watch(utangPiutangTertampilProvider);
    final dataTertampil = seluruhData
        .where((item) => item.tipe == _tipeAktif)
        .toList();
    final filterAktif = ref.watch(filterUtangProvider);
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final judulBulan = filterAktif.rentangWaktu != null
        ? '${DateFormat('dd MMM').format(filterAktif.rentangWaktu!.start)} - ${DateFormat('dd MMM').format(filterAktif.rentangWaktu!.end)}'
        : DateFormat('MMM yyyy').format(filterAktif.bulanSpesifik);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton<TipeUtangPiutang>(
                value: _tipeAktif,
                dropdownColor: Theme.of(context).appBarTheme.backgroundColor,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                iconEnabledColor: Colors.white,
                items: const [
                  DropdownMenuItem(
                    value: TipeUtangPiutang.utang,
                    child: Text('Utang'),
                  ),
                  DropdownMenuItem(
                    value: TipeUtangPiutang.piutang,
                    child: Text('Piutang'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _tipeAktif = val);
                },
              ),
            ),
            const SizedBox(width: 16),
            InkWell(
              onTap: () => _jumpToMonth(context, ref),
              child: Row(
                children: [
                  Text(judulBulan, style: const TextStyle(fontSize: 14)),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Logika filter (akun, rentang waktu)
            },
          ),
        ],
      ),
      body: dataTertampil.isEmpty
          ? Center(child: Text('Belum ada data ${_tipeAktif.name}.'))
          : ListView.builder(
              itemCount: dataTertampil.length,
              itemBuilder: (context, index) {
                final item = dataTertampil[index];
                final statusTeks = item.statusLunas
                    ? '(Lunas)'
                    : '(Belum Lunas)';

                return ListTile(
                  onTap: item.statusLunas
                      ? null
                      : () => showDialog(
                          context: context,
                          builder: (_) => DialogPelunasan(data: item),
                        ),
                  onLongPress: () => _aksiLongPress(item),
                  leading: Icon(
                    _tipeAktif == TipeUtangPiutang.utang
                        ? Icons.money_off
                        : Icons.attach_money,
                    color: item.statusLunas
                        ? Colors.grey
                        : (_tipeAktif == TipeUtangPiutang.utang
                              ? Colors.red
                              : Colors.green),
                  ),
                  title: Text('${item.pihakTerkait} $statusTeks'),
                  subtitle: Text(
                    'Tenggat: ${DateFormat('dd MMM yyyy').format(item.tenggatWaktu)}',
                  ),
                  trailing: Text(
                    currencyFormatter.format(item.nominal),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: item.statusLunas
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tampilkanPilihanForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
