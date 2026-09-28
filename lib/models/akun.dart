class Akun {
  final int? id;
  final String nama;
  final double saldoAwal;

  Akun({this.id, required this.nama, required this.saldoAwal});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nama': nama, 'saldo_awal': saldoAwal};
  }
}
