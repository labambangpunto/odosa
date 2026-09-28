import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaksi.dart';
import 'master_data_provider.dart';

class FilterTransaksi {
  final DateTime tanggalSpesifik; // Untuk pagination harian / jump to page
  final DateTimeRange? rentangWaktu; // Untuk infinity scroll rentang waktu
  final int? idLabel;
  final int? idAkun;
  final TipeTransaksi? tipe;

  FilterTransaksi({
    required this.tanggalSpesifik,
    this.rentangWaktu,
    this.idLabel,
    this.idAkun,
    this.tipe,
  });

  FilterTransaksi copyWith({
    DateTime? tanggalSpesifik,
    DateTimeRange? rentangWaktu,
    int? idLabel,
    int? idAkun,
    TipeTransaksi? tipe,
    bool clearRentangWaktu = false,
  }) {
    return FilterTransaksi(
      tanggalSpesifik: tanggalSpesifik ?? this.tanggalSpesifik,
      rentangWaktu: clearRentangWaktu
          ? null
          : (rentangWaktu ?? this.rentangWaktu),
      idLabel: idLabel ?? this.idLabel,
      idAkun: idAkun ?? this.idAkun,
      tipe: tipe ?? this.tipe,
    );
  }
}

// Inisialisasi default filter pada hari ini
final filterTransaksiProvider = StateProvider<FilterTransaksi>((ref) {
  final now = DateTime.now();
  return FilterTransaksi(
    tanggalSpesifik: DateTime(now.year, now.month, now.day),
  );
});

// Computed provider untuk memfilter data reaktif
final transaksiTertampilProvider = Provider<List<Transaksi>>((ref) {
  final seluruhTransaksi = ref.watch(transaksiListProvider);
  final filter = ref.watch(filterTransaksiProvider);

  return seluruhTransaksi.where((tx) {
    // 1. Filter Rentang Waktu atau Harian
    bool passDate = false;
    if (filter.rentangWaktu != null) {
      passDate =
          tx.tanggalWaktu.isAfter(filter.rentangWaktu!.start) &&
          tx.tanggalWaktu.isBefore(
            filter.rentangWaktu!.end.add(const Duration(days: 1)),
          );
    } else {
      passDate =
          tx.tanggalWaktu.year == filter.tanggalSpesifik.year &&
          tx.tanggalWaktu.month == filter.tanggalSpesifik.month &&
          tx.tanggalWaktu.day == filter.tanggalSpesifik.day;
    }
    if (!passDate) return false;

    // 2. Filter Akun
    if (filter.idAkun != null) {
      if (tx.idAkunSumber != filter.idAkun &&
          tx.idAkunTujuan != filter.idAkun) {
        return false;
      }
    }

    // 3. Filter Label
    if (filter.idLabel != null) {
      if (tx.idLabel != filter.idLabel) return false;
    }

    // 4. Filter Jenis Transaksi
    if (filter.tipe != null) {
      if (tx.tipe != filter.tipe) return false;
    }

    return true;
  }).toList();
});
