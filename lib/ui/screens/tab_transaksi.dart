import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../controllers/master_data_provider.dart';
import '../../models/transaksi.dart';
import '../../controllers/filter_transaksi_provider.dart';
import 'form_pengeluaran.dart';
import 'form_pemasukan.dart';
import 'form_transfer_antarakun.dart';

class TabTransaksi extends ConsumerStatefulWidget {
  const TabTransaksi({super.key});

  @override
  ConsumerState<TabTransaksi> createState() => _TabTransaksiState();
}

class _TabTransaksiState extends ConsumerState<TabTransaksi> {
  void _tampilkanPilihanForm() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.arrow_upward, color: Colors.red),
                title: const Text('Pengeluaran'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FormPengeluaran()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.green),
                title: const Text('Pemasukan'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FormPemasukan()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.swap_horiz, color: Colors.blue),
                title: const Text('Transfer Antarakun'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FormTransferAntarakun(),
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

  void _aksiLongPress(Transaksi transaksi) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Aksi Transaksi'),
          content: const Text('Pilih aksi untuk transaksi ini.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Buka form edit sesuai tipe transaksi
                Widget formWidget;
                if (transaksi.tipe == TipeTransaksi.pengeluaran) {
                  formWidget = FormPengeluaran(dataEdit: transaksi);
                } else if (transaksi.tipe == TipeTransaksi.pemasukan) {
                  formWidget = FormPemasukan(
                    dataEdit: transaksi,
                  ); // Asumsi FormPemasukan sudah diupdate
                } else {
                  formWidget = FormTransferAntarakun(
                    dataEdit: transaksi,
                  ); // Asumsi sudah diupdate
                }
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
                    .read(transaksiListProvider.notifier)
                    .deleteTransaksi(transaksi.id!);
                Navigator.pop(context);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _tampilkanFilter(BuildContext context, WidgetRef ref) {
    final filterAktif = ref.read(filterTransaksiProvider);
    final daftarAkun = ref.read(akunListProvider);
    final daftarLabel = ref.read(labelListProvider);

    // State lokal untuk dialog filter
    int? tempIdAkun = filterAktif.idAkun;
    int? tempIdLabel = filterAktif.idLabel;
    TipeTransaksi? tempTipe = filterAktif.tipe;
    DateTimeRange? tempRentang = filterAktif.rentangWaktu;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateLokal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Transaksi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<int?>(
                    initialValue: tempIdAkun,
                    decoration: const InputDecoration(
                      labelText: 'Akun',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Semua Akun'),
                      ),
                      ...daftarAkun.map(
                        (a) =>
                            DropdownMenuItem(value: a.id, child: Text(a.nama)),
                      ),
                    ],
                    onChanged: (val) => setStateLokal(() => tempIdAkun = val),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<int?>(
                    initialValue: tempIdLabel,
                    decoration: const InputDecoration(
                      labelText: 'Label',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Semua Label'),
                      ),
                      ...daftarLabel.map(
                        (l) =>
                            DropdownMenuItem(value: l.id, child: Text(l.nama)),
                      ),
                    ],
                    onChanged: (val) => setStateLokal(() => tempIdLabel = val),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<TipeTransaksi?>(
                    initialValue: tempTipe,
                    decoration: const InputDecoration(
                      labelText: 'Jenis Transaksi',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Semua Jenis')),
                      DropdownMenuItem(
                        value: TipeTransaksi.pengeluaran,
                        child: Text('Pengeluaran'),
                      ),
                      DropdownMenuItem(
                        value: TipeTransaksi.pemasukan,
                        child: Text('Pemasukan'),
                      ),
                      DropdownMenuItem(
                        value: TipeTransaksi.transfer,
                        child: Text('Transfer'),
                      ),
                    ],
                    onChanged: (val) => setStateLokal(() => tempTipe = val),
                  ),
                  const SizedBox(height: 12),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Rentang Waktu'),
                    subtitle: Text(
                      tempRentang != null
                          ? '${DateFormat('dd MMM').format(tempRentang!.start)} - ${DateFormat('dd MMM').format(tempRentang!.end)}'
                          : 'Tidak aktif (hanya harian)',
                    ),
                    trailing: const Icon(Icons.date_range),
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        initialDateRange: tempRentang,
                      );
                      if (picked != null) {
                        setStateLokal(() => tempRentang = picked);
                      }
                    },
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Reset Filter
                          ref
                              .read(filterTransaksiProvider.notifier)
                              .state = FilterTransaksi(
                            tanggalSpesifik: filterAktif.tanggalSpesifik,
                          );
                          Navigator.pop(ctx);
                        },
                        child: const Text('Reset'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Terapkan Filter
                          ref
                              .read(filterTransaksiProvider.notifier)
                              .state = filterAktif.copyWith(
                            idAkun: tempIdAkun,
                            idLabel: tempIdLabel,
                            tipe: tempTipe,
                            rentangWaktu: tempRentang,
                            clearRentangWaktu: tempRentang == null,
                          );
                          Navigator.pop(ctx);
                        },
                        child: const Text('Terapkan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildListTransaksi(List<Transaksi> daftarTransaksi) {
    List<Widget> widgets = [];
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    for (var tx in daftarTransaksi) {
      final nominalTeks = currencyFormatter.format(tx.nominal);
      final nominalDibagi = currencyFormatter.format(tx.nominal / tx.kuantitas);

      // Render induk transaksi
      widgets.add(
        ListTile(
          onLongPress: () => _aksiLongPress(tx),
          leading: Icon(
            tx.tipe == TipeTransaksi.pengeluaran
                ? Icons.arrow_upward
                : tx.tipe == TipeTransaksi.pemasukan
                ? Icons.arrow_downward
                : Icons.swap_horiz,
            color: tx.tipe == TipeTransaksi.pengeluaran
                ? Colors.red
                : tx.tipe == TipeTransaksi.pemasukan
                ? Colors.green
                : Colors.blue,
          ),
          title: Text(
            tx.catatan.isNotEmpty ? tx.catatan : 'Transaksi tanpa catatan',
          ),
          subtitle: Text(
            DateFormat('dd MMM yyyy, HH:mm').format(tx.tanggalWaktu),
          ),
          trailing: Text(
            tx.kuantitas > 1 ? '$nominalTeks (Total)' : nominalTeks,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );

      // Render duplikasi visual jika kuantitas > 1
      if (tx.kuantitas > 1) {
        for (int i = 0; i < tx.kuantitas; i++) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(left: 40.0), // Indentasi khusus
              child: ListTile(
                onLongPress: () => _aksiLongPress(tx),
                dense: true,
                leading: const Icon(Icons.subdirectory_arrow_right, size: 20),
                title: Text('Item ${i + 1}'),
                trailing: Text(nominalDibagi),
              ),
            ),
          );
        }
      }
      widgets.add(const Divider(height: 1));
    }
    return widgets;
  }

  Future<void> _jumpToPage(BuildContext context, WidgetRef ref) async {
    final filterAktif = ref.read(filterTransaksiProvider);
    final date = await showDatePicker(
      context: context,
      initialDate: filterAktif.tanggalSpesifik,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      // Mengubah state ke hari yang dipilih dan menghapus filter rentang waktu
      ref.read(filterTransaksiProvider.notifier).state = filterAktif.copyWith(
        tanggalSpesifik: date,
        clearRentangWaktu: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengonsumsi provider hasil filter, bukan keseluruhan data
    final daftarTransaksiTertampil = ref.watch(transaksiTertampilProvider);
    final filterAktif = ref.watch(filterTransaksiProvider);

    final judulTanggal = filterAktif.rentangWaktu != null
        ? '${DateFormat('dd MMM').format(filterAktif.rentangWaktu!.start)} - ${DateFormat('dd MMM').format(filterAktif.rentangWaktu!.end)}'
        : DateFormat('dd MMM yyyy').format(filterAktif.tanggalSpesifik);

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () => _jumpToPage(context, ref),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [Text(judulTanggal), const Icon(Icons.arrow_drop_down)],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _tampilkanFilter(context, ref),
          ),
        ],
      ),
      body: daftarTransaksiTertampil.isEmpty
          ? const Center(child: Text('Tidak ada transaksi pada periode ini.'))
          : ListView(children: _buildListTransaksi(daftarTransaksiTertampil)),
      floatingActionButton: FloatingActionButton(
        onPressed: _tampilkanPilihanForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
