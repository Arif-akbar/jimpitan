import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimpitan_digital/shared/models/jimpitan_model.dart';
import 'package:jimpitan_digital/core/data/dummy_data.dart';
import 'package:jimpitan_digital/features/petugas/presentation/providers/jimpitan_list_notifier.dart';

// ─── Model Laporan Harian ────────────────────────────────────────────────────

class LaporanHarian {
  final DateTime tanggal;
  final List<JimpitanModel> records;
  final int totalDiambil;
  final int totalKosong;
  final int totalRumah;

  const LaporanHarian({
    required this.tanggal,
    required this.records,
    required this.totalDiambil,
    required this.totalKosong,
    required this.totalRumah,
  });

  double get persentaseDiambil =>
      totalRumah == 0 ? 0 : (totalDiambil / totalRumah) * 100;
}

// ─── Model Dashboard Stats ────────────────────────────────────────────────────

class BendaharaStats {
  final int totalDiambilHariIni;
  final int totalKosongHariIni;
  final int totalRumah;
  final int totalDiambilBulanIni;

  const BendaharaStats({
    required this.totalDiambilHariIni,
    required this.totalKosongHariIni,
    required this.totalRumah,
    required this.totalDiambilBulanIni,
  });
}

// ─── Providers ───────────────────────────────────────────────────────────────

/// Dashboard stats untuk bendahara
final bendaharaDashboardStatsProvider = Provider<BendaharaStats>((ref) {
  final all = ref.watch(jimpitanListNotifierProvider);
  final today = DateTime.now();

  final todayList = all.where((j) =>
      j.tanggal.year == today.year &&
      j.tanggal.month == today.month &&
      j.tanggal.day == today.day).toList();

  final monthList = all.where((j) =>
      j.tanggal.year == today.year &&
      j.tanggal.month == today.month).toList();

  return BendaharaStats(
    totalDiambilHariIni:
        todayList.where((j) => j.status == JimpitanStatus.diambil).length,
    totalKosongHariIni:
        todayList.where((j) => j.status == JimpitanStatus.kosong).length,
    totalRumah: DummyData.semuaRumah.length,
    totalDiambilBulanIni:
        monthList.where((j) => j.status == JimpitanStatus.diambil).length,
  );
});

/// Laporan harian (grouped by date, sorted terbaru)
final laporanHarianProvider = Provider<List<LaporanHarian>>((ref) {
  final all = ref.watch(jimpitanListNotifierProvider);

  final Map<String, List<JimpitanModel>> grouped = {};
  for (final j in all) {
    final key =
        '${j.tanggal.year}-${j.tanggal.month.toString().padLeft(2, '0')}-${j.tanggal.day.toString().padLeft(2, '0')}';
    grouped.putIfAbsent(key, () => []).add(j);
  }

  return grouped.entries
      .map((e) => LaporanHarian(
            tanggal: DateTime.parse(e.key),
            records: e.value,
            totalDiambil:
                e.value.where((j) => j.status == JimpitanStatus.diambil).length,
            totalKosong:
                e.value.where((j) => j.status == JimpitanStatus.kosong).length,
            totalRumah: e.value.length,
          ))
      .toList()
    ..sort((a, b) => b.tanggal.compareTo(a.tanggal));
});

/// Semua jimpitan hari ini (semua RT)
final jimpitanHariIniAllProvider = Provider<List<JimpitanModel>>((ref) {
  final all = ref.watch(jimpitanListNotifierProvider);
  final today = DateTime.now();
  return all
      .where((j) =>
          j.tanggal.year == today.year &&
          j.tanggal.month == today.month &&
          j.tanggal.day == today.day)
      .toList()
    ..sort((a, b) => (b.waktuPengambilan ?? b.tanggal)
        .compareTo(a.waktuPengambilan ?? a.tanggal));
});
