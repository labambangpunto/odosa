import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaksi.dart';
import 'master_data_provider.dart';

// Menghitung total pemasukan dan pengeluaran bulan ini
final ringkasanBulananProvider = Provider<Map<String, double>>((ref) {
  final transaksiList = ref.watch(transaksiListProvider);
  final now = DateTime.now();

  double totalPemasukan = 0;
  double totalPengeluaran = 0;

  for (var tx in transaksiList) {
    if (tx.tanggalWaktu.year == now.year &&
        tx.tanggalWaktu.month == now.month) {
      if (tx.tipe == TipeTransaksi.pemasukan) {
        totalPemasukan += tx.nominal;
      } else if (tx.tipe == TipeTransaksi.pengeluaran) {
        totalPengeluaran += (tx.nominal + tx.biayaTambahan);
      } else if (tx.tipe == TipeTransaksi.transfer) {
        totalPengeluaran +=
            tx.biayaTambahan; // Biaya transfer dihitung sebagai pengeluaran
      }
    }
  }

  return {'pemasukan': totalPemasukan, 'pengeluaran': totalPengeluaran};
});

// Menghitung saldo akhir tiap akun (Saldo Awal + Pemasukan - Pengeluaran +/- Transfer)
final saldoAkunProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final akunList = ref.watch(akunListProvider);
  final transaksiList = ref.watch(transaksiListProvider);

  List<Map<String, dynamic>> hasil = [];
  double totalKeseluruhan = 0;

  for (var akun in akunList) {
    double saldo = akun.saldoAwal;

    for (var tx in transaksiList) {
      if (tx.idAkunSumber == akun.id) {
        if (tx.tipe == TipeTransaksi.pengeluaran) {
          saldo -= (tx.nominal + tx.biayaTambahan);
        } else if (tx.tipe == TipeTransaksi.transfer) {
          saldo -= (tx.nominal + tx.biayaTambahan);
        }
      }
      if (tx.idAkunTujuan == akun.id) {
        if (tx.tipe == TipeTransaksi.pemasukan) {
          saldo += tx.nominal;
        } else if (tx.tipe == TipeTransaksi.transfer) {
          saldo += tx.nominal;
        }
      }
    }

    totalKeseluruhan += saldo;
    hasil.add({'akun': akun, 'saldo': saldo});
  }

  // Menyimpan total keseluruhan di index terakhir untuk efisiensi
  return [
    {'totalKeseluruhan': totalKeseluruhan},
    ...hasil,
  ];
});
