enum JimpitanStatus { diambil, kosong, belum }

extension JimpitanStatusExt on JimpitanStatus {
  String get label {
    switch (this) {
      case JimpitanStatus.diambil:
        return 'Diambil';
      case JimpitanStatus.kosong:
        return 'Kosong';
      case JimpitanStatus.belum:
        return 'Belum';
    }
  }
}

class JimpitanModel {
  final String id;
  final String rumahId;
  final String nomorRumah;
  final String namaKepalaKeluarga;
  final String sesiId;
  final DateTime tanggal;
  final JimpitanStatus status;
  final String? fotoUrl;
  final DateTime? waktuPengambilan;
  final String? lokasi;
  final String? petugasId;
  final String? petugasNama;

  const JimpitanModel({
    required this.id,
    required this.rumahId,
    required this.nomorRumah,
    required this.namaKepalaKeluarga,
    required this.sesiId,
    required this.tanggal,
    required this.status,
    this.fotoUrl,
    this.waktuPengambilan,
    this.lokasi,
    this.petugasId,
    this.petugasNama,
  });

  JimpitanModel copyWith({
    String? id,
    String? rumahId,
    String? nomorRumah,
    String? namaKepalaKeluarga,
    String? sesiId,
    DateTime? tanggal,
    JimpitanStatus? status,
    String? fotoUrl,
    DateTime? waktuPengambilan,
    String? lokasi,
    String? petugasId,
    String? petugasNama,
  }) {
    return JimpitanModel(
      id: id ?? this.id,
      rumahId: rumahId ?? this.rumahId,
      nomorRumah: nomorRumah ?? this.nomorRumah,
      namaKepalaKeluarga: namaKepalaKeluarga ?? this.namaKepalaKeluarga,
      sesiId: sesiId ?? this.sesiId,
      tanggal: tanggal ?? this.tanggal,
      status: status ?? this.status,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      waktuPengambilan: waktuPengambilan ?? this.waktuPengambilan,
      lokasi: lokasi ?? this.lokasi,
      petugasId: petugasId ?? this.petugasId,
      petugasNama: petugasNama ?? this.petugasNama,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is JimpitanModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
