class RumahModel {
  final String id;
  final String nomorRumah;
  final String namaKepalaKeluarga;
  final String alamat;
  final String rt;

  const RumahModel({
    required this.id,
    required this.nomorRumah,
    required this.namaKepalaKeluarga,
    required this.alamat,
    required this.rt,
  });

  // QR code berisi ID rumah
  String get qrCode => id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RumahModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'RumahModel(id: $id, nomor: $nomorRumah, rt: $rt)';
}
