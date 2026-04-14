class JadwalRondaModel {
  final String id;
  // 1: Senin, 2: Selasa, dst
  final int hari;
  final String rt;
  final List<String> petugasNames;

  const JadwalRondaModel({
    required this.id,
    required this.hari,
    required this.rt,
    required this.petugasNames,
  });

  String get namaHari {
    switch (hari) {
      case 1: return 'Senin';
      case 2: return 'Selasa';
      case 3: return 'Rabu';
      case 4: return 'Kamis';
      case 5: return 'Jumat';
      case 6: return 'Sabtu';
      case 7: return 'Minggu';
      default: return 'Tidak Diketahui';
    }
  }
}
