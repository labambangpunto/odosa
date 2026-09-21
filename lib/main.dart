import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

import 'dart:convert';

import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

// 1. MODEL UPDATE
enum TipeTransaksi { pemasukan, pengeluaran }

class Transaksi {
  final int? id;
  final String judul;
  final double jumlah;
  final TipeTransaksi tipe;
  final DateTime tanggal;

  Transaksi({
    this.id,
    required this.judul,
    required this.jumlah,
    required this.tipe,
    required this.tanggal,
  });

  // Konversi dari objek ke Map untuk disimpan di SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'jumlah': jumlah,
      'tipe': tipe == TipeTransaksi.pemasukan ? 1 : 0,
      'tanggal': tanggal.toIso8601String(),
    };
  }

  // Konversi dari Map SQLite ke objek Transaksi
  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      id: map['id'],
      judul: map['judul'],
      jumlah: map['jumlah'],
      tipe: map['tipe'] == 1
          ? TipeTransaksi.pemasukan
          : TipeTransaksi.pengeluaran,
      tanggal: DateTime.parse(map['tanggal']),
    );
  }
}

// 2. DATABASE HELPER
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('transaksi.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final dbLocation = path.join(dbPath, filePath); // <-- Gunakan path.join

    return await openDatabase(dbLocation, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE transaksi (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      judul TEXT NOT NULL,
      jumlah REAL NOT NULL,
      tipe INTEGER NOT NULL,
      tanggal TEXT NOT NULL
    )
    ''');
  }

  Future<int> insert(Transaksi transaksi) async {
    final db = await instance.database;
    return await db.insert('transaksi', transaksi.toMap());
  }

  Future<List<Transaksi>> readAll() async {
    final db = await instance.database;
    final result = await db.query('transaksi', orderBy: 'tanggal DESC');
    return result.map((json) => Transaksi.fromMap(json)).toList();
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('transaksi', where: 'id = ?', whereArgs: [id]);
  }
}

// 3. UI INTEGRATION
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Transaksi> _daftarTransaksi = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // Tarik data dari SQLite
  Future _refreshData() async {
    setState(() => _isLoading = true);
    _daftarTransaksi = await DatabaseHelper.instance.readAll();
    setState(() => _isLoading = false);
  }

  double get totalPemasukan => _daftarTransaksi
      .where((t) => t.tipe == TipeTransaksi.pemasukan)
      .fold(0, (sum, t) => sum + t.jumlah);

  double get totalPengeluaran => _daftarTransaksi
      .where((t) => t.tipe == TipeTransaksi.pengeluaran)
      .fold(0, (sum, t) => sum + t.jumlah);

  double get saldo => totalPemasukan - totalPengeluaran;

  // Insert ke SQLite lalu refresh UI
  void _tambahTransaksi(String judul, double jumlah, TipeTransaksi tipe) async {
    final transaksi = Transaksi(
      judul: judul,
      jumlah: jumlah,
      tipe: tipe,
      tanggal: DateTime.now(),
    );

    await DatabaseHelper.instance.insert(transaksi);
    _refreshData();
  }

  // Delete dari SQLite lalu refresh UI
  void _hapusTransaksi(int id) async {
    await DatabaseHelper.instance.delete(id);
    _refreshData();
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

  Future<void> _exportData(String format) async {
    // 1. Ambil semua data dari database
    final data = await DatabaseHelper.instance.readAll();

    if (!mounted) return;

    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk diekspor')),
      );
      return;
    }

    String content = '';
    String fileName = 'transaksi_${DateTime.now().millisecondsSinceEpoch}';
    String ext = '';
    MimeType mimeType;

    // 2. Format data sesuai pilihan
    if (format == 'json') {
      List<Map<String, dynamic>> jsonData = data.map((e) => e.toMap()).toList();
      content = jsonEncode(jsonData);
      ext = 'json';
      mimeType = MimeType.json;
    } else {
      content = 'ID,Judul,Jumlah,Tipe,Tanggal\n';
      for (var t in data) {
        String tipeStr = t.tipe == TipeTransaksi.pemasukan
            ? 'Pemasukan'
            : 'Pengeluaran';
        content +=
            '${t.id},"${t.judul}",${t.jumlah},$tipeStr,${t.tanggal.toIso8601String()}\n';
      }
      ext = 'csv';
      mimeType = MimeType.csv;
    }

    // 3. Konversi string ke format Bytes
    Uint8List bytes = Uint8List.fromList(utf8.encode(content));

    try {
      // 1. Ubah String? menjadi String
      // 2. Ubah ext: menjadi customExtension:
      String path = await FileSaver.instance.saveFile(
        name: '$fileName.$ext',
        bytes: bytes,
        mimeType: mimeType,
      );

      if (!mounted) return;

      // 3. Hapus pengecekan 'path != null &&'
      if (path.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil disimpan di: $path'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatRupiah(double angka) {
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
      appBar: AppBar(
        title: const Text('Catatan Keuangan'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _exportData(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'csv',
                child: Text('Export ke CSV (Excel)'),
              ),
              const PopupMenuItem(value: 'json', child: Text('Export ke JSON')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                            final isPemasukan =
                                t.tipe == TipeTransaksi.pemasukan;
                            return Dismissible(
                              key: ValueKey(t.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (_) => _hapusTransaksi(t.id!),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isPemasukan
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                  child: Icon(
                                    isPemasukan
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: isPemasukan
                                        ? Colors.green
                                        : Colors.red,
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
                                    color: isPemasukan
                                        ? Colors.green
                                        : Colors.red,
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
    // Widget Form tetap sama seperti aslinya
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
          // Hapus RadioGroup bawaan dan ganti manual jika RadioGroup tidak dikenali di Flutter versi tertentu
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
