enum SesiStatus { aktif, selesai }

class SesiRondaModel {
  final String id;
  final String petugasId;
  final String petugasNama;
  final String rt;
  final DateTime mulai;
  final DateTime? selesai;
  final SesiStatus status;

  const SesiRondaModel({
    required this.id,
    required this.petugasId,
    required this.petugasNama,
    required this.rt,
    required this.mulai,
    this.selesai,
    required this.status,
  });

  SesiRondaModel copyWith({
    String? id,
    String? petugasId,
    String? petugasNama,
    String? rt,
    DateTime? mulai,
    DateTime? selesai,
    SesiStatus? status,
  }) {
    return SesiRondaModel(
      id: id ?? this.id,
      petugasId: petugasId ?? this.petugasId,
      petugasNama: petugasNama ?? this.petugasNama,
      rt: rt ?? this.rt,
      mulai: mulai ?? this.mulai,
      selesai: selesai ?? this.selesai,
      status: status ?? this.status,
    );
  }
}
