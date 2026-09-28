enum TipeUtangPiutang { utang, piutang }

class UtangPiutang {
  final int? id;
  final TipeUtangPiutang tipe;
  final double nominal;
  final String pihakTerkait;
  final int idAkun;
  final DateTime tanggalWaktu;
  final DateTime tenggatWaktu;
  final String catatan;
  final bool statusLunas;

  UtangPiutang({
    this.id,
    required this.tipe,
    required this.nominal,
    required this.pihakTerkait,
    required this.idAkun,
    required this.tanggalWaktu,
    required this.tenggatWaktu,
    this.catatan = '',
    this.statusLunas = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipe': tipe.index,
      'nominal': nominal,
      'pihak_terkait': pihakTerkait,
      'id_akun': idAkun,
      'tanggal_waktu': tanggalWaktu.toIso8601String(),
      'tenggat_waktu': tenggatWaktu.toIso8601String(),
      'catatan': catatan,
      'status_lunas': statusLunas ? 1 : 0,
    };
  }
}
