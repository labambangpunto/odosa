import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/utang_piutang.dart';
import 'utang_piutang_provider.dart';

class FilterUtang {
  final DateTime bulanSpesifik;
  final DateTimeRange? rentangWaktu;
  final int? idAkun;

  FilterUtang({required this.bulanSpesifik, this.rentangWaktu, this.idAkun});

  FilterUtang copyWith({
    DateTime? bulanSpesifik,
    DateTimeRange? rentangWaktu,
    int? idAkun,
    bool clearRentangWaktu = false,
  }) {
    return FilterUtang(
      bulanSpesifik: bulanSpesifik ?? this.bulanSpesifik,
      rentangWaktu: clearRentangWaktu
          ? null
          : (rentangWaktu ?? this.rentangWaktu),
      idAkun: idAkun ?? this.idAkun,
    );
  }
}

final filterUtangProvider = StateProvider<FilterUtang>((ref) {
  final now = DateTime.now();
  return FilterUtang(bulanSpesifik: DateTime(now.year, now.month));
});

final utangPiutangTertampilProvider = Provider<List<UtangPiutang>>((ref) {
  final seluruhData = ref.watch(utangPiutangListProvider);
  final filter = ref.watch(filterUtangProvider);

  return seluruhData.where((item) {
    // Filter Bulan atau Rentang Waktu
    bool passDate = false;
    if (filter.rentangWaktu != null) {
      passDate =
          item.tanggalWaktu.isAfter(filter.rentangWaktu!.start) &&
          item.tanggalWaktu.isBefore(
            filter.rentangWaktu!.end.add(const Duration(days: 1)),
          );
    } else {
      passDate =
          item.tanggalWaktu.year == filter.bulanSpesifik.year &&
          item.tanggalWaktu.month == filter.bulanSpesifik.month;
    }
    if (!passDate) return false;

    // Filter Akun
    if (filter.idAkun != null) {
      if (item.idAkun != filter.idAkun) return false;
    }

    return true;
  }).toList();
});
