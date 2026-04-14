enum TipeKeuangan { pemasukan, pengeluaran }

class KeuanganModel {
  final String id;
  final TipeKeuangan tipe;
  final int nominal;
  final String keterangan;
  final DateTime tanggal;

  const KeuanganModel({
    required this.id,
    required this.tipe,
    required this.nominal,
    required this.keterangan,
    required this.tanggal,
  });

  KeuanganModel copyWith({
    String? id,
    TipeKeuangan? tipe,
    int? nominal,
    String? keterangan,
    DateTime? tanggal,
  }) {
    return KeuanganModel(
      id: id ?? this.id,
      tipe: tipe ?? this.tipe,
      nominal: nominal ?? this.nominal,
      keterangan: keterangan ?? this.keterangan,
      tanggal: tanggal ?? this.tanggal,
    );
  }
}
