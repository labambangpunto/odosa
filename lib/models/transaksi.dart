enum TipeTransaksi { pengeluaran, pemasukan, transfer }

class Transaksi {
  final int? id;
  final TipeTransaksi tipe;
  final double nominal;
  final double biayaTambahan;
  final int kuantitas;
  final int? idAkunSumber;
  final int? idAkunTujuan;
  final int? idLabel;
  final DateTime tanggalWaktu;
  final String catatan;

  Transaksi({
    this.id,
    required this.tipe,
    required this.nominal,
    this.biayaTambahan = 0.0,
    this.kuantitas = 1,
    this.idAkunSumber,
    this.idAkunTujuan,
    this.idLabel,
    required this.tanggalWaktu,
    this.catatan = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipe': tipe.index,
      'nominal': nominal,
      'biaya_tambahan': biayaTambahan,
      'kuantitas': kuantitas,
      'id_akun_sumber': idAkunSumber,
      'id_akun_tujuan': idAkunTujuan,
      'id_label': idLabel,
      'tanggal_waktu': tanggalWaktu.toIso8601String(),
      'catatan': catatan,
    };
  }
}
