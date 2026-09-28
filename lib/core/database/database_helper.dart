import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('keuangan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path = '';

    if (Platform.isAndroid) {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    } else if (Platform.isWindows || Platform.isLinux) {
      final appSupportDir = await getApplicationSupportDirectory();
      path = join(appSupportDir.path, filePath);
    }

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(version: 1, onCreate: _createDB),
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE akun (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL UNIQUE,
        saldo_awal REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE label (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE transaksi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipe INTEGER NOT NULL,
        nominal REAL NOT NULL,
        biaya_tambahan REAL NOT NULL DEFAULT 0.0,
        kuantitas INTEGER NOT NULL DEFAULT 1,
        id_akun_sumber INTEGER,
        id_akun_tujuan INTEGER,
        id_label INTEGER,
        tanggal_waktu TEXT NOT NULL,
        catatan TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE utang_piutang (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipe INTEGER NOT NULL,
        nominal REAL NOT NULL,
        pihak_terkait TEXT NOT NULL,
        id_akun INTEGER NOT NULL,
        tanggal_waktu TEXT NOT NULL,
        tenggat_waktu TEXT NOT NULL,
        catatan TEXT,
        status_lunas INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('transaksi');
      await txn.delete('utang_piutang');
      await txn.delete('akun');
      await txn.delete('label');
    });
  }
}
