import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Keuangan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

// Model sederhana untuk satu transaksi
enum TipeTransaksi { pemasukan, pengeluaran }

class Transaksi {
  final String judul;
  final double jumlah;
  final TipeTransaksi tipe;
  final DateTime tanggal;

  Transaksi({
    required this.judul,
    required this.jumlah,
    required this.tipe,
    required this.tanggal,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Transaksi> _daftarTransaksi = [];

  double get totalPemasukan => _daftarTransaksi
      .where((t) => t.tipe == TipeTransaksi.pemasukan)
      .fold(0, (sum, t) => sum + t.jumlah);

  double get totalPengeluaran => _daftarTransaksi
      .where((t) => t.tipe == TipeTransaksi.pengeluaran)
      .fold(0, (sum, t) => sum + t.jumlah);

  double get saldo => totalPemasukan - totalPengeluaran;

  void _tambahTransaksi(String judul, double jumlah, TipeTransaksi tipe) {
    setState(() {
      _daftarTransaksi.insert(
        0,
        Transaksi(
          judul: judul,
          jumlah: jumlah,
          tipe: tipe,
          tanggal: DateTime.now(),
        ),
      );
    });
  }

  void _hapusTransaksi(int index) {
    setState(() {
      _daftarTransaksi.removeAt(index);
    });
  }

  void _bukaFormTambah() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: FormTambahTransaksi(onSimpan: _tambahTransaksi),
        );
      },
    );
  }

  String _formatRupiah(double angka) {
    // Format sederhana pemisah ribuan tanpa package tambahan
    final s = angka.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posisiDariKanan = s.length - i;
      buffer.write(s[i]);
      if (posisiDariKanan > 1 && posisiDariKanan % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp $buffer';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catatan Keuangan'), centerTitle: true),
      body: Column(
        children: [
          _buildRingkasan(),
          const Divider(height: 1),
          Expanded(
            child: _daftarTransaksi.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada transaksi.\nTekan tombol + untuk menambah.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _daftarTransaksi.length,
                    itemBuilder: (context, index) {
                      final t = _daftarTransaksi[index];
                      final isPemasukan = t.tipe == TipeTransaksi.pemasukan;
                      return Dismissible(
                        key: ValueKey(t.tanggal.microsecondsSinceEpoch),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _hapusTransaksi(index),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isPemasukan
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            child: Icon(
                              isPemasukan
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: isPemasukan ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(t.judul),
                          subtitle: Text(
                            '${t.tanggal.day}/${t.tanggal.month}/${t.tanggal.year}',
                          ),
                          trailing: Text(
                            (isPemasukan ? '+ ' : '- ') +
                                _formatRupiah(t.jumlah),
                            style: TextStyle(
                              color: isPemasukan ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _bukaFormTambah,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRingkasan() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).colorScheme.primary,
      child: Column(
        children: [
          const Text(
            'Saldo Saat Ini',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            _formatRupiah(saldo),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRingkasanItem(
                label: 'Pemasukan',
                nilai: totalPemasukan,
                icon: Icons.arrow_downward,
                warna: Colors.greenAccent,
              ),
              _buildRingkasanItem(
                label: 'Pengeluaran',
                nilai: totalPengeluaran,
                icon: Icons.arrow_upward,
                warna: Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRingkasanItem({
    required String label,
    required double nilai,
    required IconData icon,
    required Color warna,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: warna, size: 18),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _formatRupiah(nilai),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Form untuk menambah transaksi baru
class FormTambahTransaksi extends StatefulWidget {
  final void Function(String judul, double jumlah, TipeTransaksi tipe) onSimpan;

  const FormTambahTransaksi({super.key, required this.onSimpan});

  @override
  State<FormTambahTransaksi> createState() => _FormTambahTransaksiState();
}

class _FormTambahTransaksiState extends State<FormTambahTransaksi> {
  final _judulController = TextEditingController();
  final _jumlahController = TextEditingController();
  TipeTransaksi _tipeTerpilih = TipeTransaksi.pengeluaran;

  @override
  void dispose() {
    _judulController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  void _simpan() {
    final judul = _judulController.text.trim();
    final jumlah = double.tryParse(_jumlahController.text.trim()) ?? 0;

    if (judul.isEmpty || jumlah <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan jumlah harus valid')),
      );
      return;
    }

    widget.onSimpan(judul, jumlah, _tipeTerpilih);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tambah Transaksi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _judulController,
            decoration: const InputDecoration(
              labelText: 'Judul (misal: Gaji, Makan siang)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _jumlahController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            decoration: const InputDecoration(
              labelText: 'Jumlah (Rp)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          RadioGroup<TipeTransaksi>(
            groupValue: _tipeTerpilih,
            onChanged: (value) {
              setState(() => _tipeTerpilih = value!);
            },
            child: Row(
              children: const [
                Expanded(
                  child: RadioListTile<TipeTransaksi>(
                    title: Text('Pemasukan'),
                    value: TipeTransaksi.pemasukan,
                  ),
                ),
                Expanded(
                  child: RadioListTile<TipeTransaksi>(
                    title: Text('Pengeluaran'),
                    value: TipeTransaksi.pengeluaran,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _simpan,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Simpan'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
