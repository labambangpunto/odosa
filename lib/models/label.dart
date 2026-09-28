class KategoriLabel {
  final int? id;
  final String nama;

  KategoriLabel({this.id, required this.nama});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nama': nama};
  }
}
