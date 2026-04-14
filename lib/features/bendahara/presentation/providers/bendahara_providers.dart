import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimpitan_digital/shared/models/jimpitan_model.dart';
import 'package:jimpitan_digital/shared/models/rumah_model.dart';
import 'package:jimpitan_digital/shared/models/jadwal_ronda_model.dart';
import 'package:jimpitan_digital/core/data/dummy_data.dart';
import 'package:jimpitan_digital/features/petugas/presentation/providers/jimpitan_list_notifier.dart';
import 'package:jimpitan_digital/core/providers/time_provider.dart';

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

// ─── Providers Utama ─────────────────────────────────────────────────────────

/// Dashboard stats untuk bendahara
final bendaharaDashboardStatsProvider = Provider<BendaharaStats>((ref) {
  final all = ref.watch(jimpitanListNotifierProvider);
  final today = ref.watch(todayProvider).value ?? DateTime.now();

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

/// Semua jimpitan hari ini (semua RT) - Auto Refresh
final jimpitanHariIniAllProvider = Provider<List<JimpitanModel>>((ref) {
  final all = ref.watch(jimpitanListNotifierProvider);
  final today = ref.watch(todayProvider).value ?? DateTime.now();
  
  return all
      .where((j) =>
          j.tanggal.year == today.year &&
          j.tanggal.month == today.month &&
          j.tanggal.day == today.day)
      .toList()
    ..sort((a, b) => (b.waktuPengambilan ?? b.tanggal)
        .compareTo(a.waktuPengambilan ?? a.tanggal));
});

// ─── Fitur Tambahan: Per-Petugas, Status Rumah, Tunggakan, Jadwal ────────────

class RekapPetugas {
  final String petugasName;
  final int totalDiambil;
  final int totalUang;

  const RekapPetugas(this.petugasName, this.totalDiambil, this.totalUang);
}

/// Rekap uang terkumpul per petugas hari ini
final rekapPetugasHariIniProvider = Provider<List<RekapPetugas>>((ref) {
  final hariIni = ref.watch(jimpitanHariIniAllProvider);
  final map = <String, int>{}; // nama -> total diambil
  
  for (final j in hariIni) {
    if (j.status == JimpitanStatus.diambil && j.petugasNama != null) {
      map[j.petugasNama!] = (map[j.petugasNama!] ?? 0) + 1;
    }
  }

  return map.entries
      .map((e) => RekapPetugas(e.key, e.value, e.value * 500))
      .toList()
    ..sort((a, b) => b.totalUang.compareTo(a.totalUang));
});


class StatusRumahInfo {
  final RumahModel rumah;
  final int totalBayarBulanIni;
  final int totalKosong3Bulan;
  final int nominalTunggakan;
  
  bool get isAktif => totalBayarBulanIni > 0;
  bool get hasTunggakan => totalKosong3Bulan >= 21;

  const StatusRumahInfo(
    this.rumah,
    this.totalBayarBulanIni,
    this.totalKosong3Bulan,
    this.nominalTunggakan,
  );
}

/// Filter Aktif/Pasif dalam 1 bulan & Tunggakan (KOSONG >= 21 hari dalam 3 bln)
final statusRumahProvider = Provider<List<StatusRumahInfo>>((ref) {
  final all = ref.watch(jimpitanListNotifierProvider);
  final today = ref.watch(todayProvider).value ?? DateTime.now();
  
  final startBulanIni = DateTime(today.year, today.month, 1);
  final start3BulanLalu = today.subtract(const Duration(days: 90));

  return DummyData.semuaRumah.map((rumah) {
    int bayarBulanIni = 0;
    int kosong3Bulan = 0;
    
    for (final j in all.where((x) => x.rumahId == rumah.id)) {
      // Hitung bayar bulan ini
      if (!j.tanggal.isBefore(startBulanIni) && j.status == JimpitanStatus.diambil) {
        bayarBulanIni++;
      }
      // Hitung kosong 3 bulan terakhir
      if (!j.tanggal.isBefore(start3BulanLalu) && j.status == JimpitanStatus.kosong) {
        kosong3Bulan++;
      }
    }

    final int tunggakan = kosong3Bulan >= 21 ? kosong3Bulan * 500 : 0;
    return StatusRumahInfo(rumah, bayarBulanIni, kosong3Bulan, tunggakan);
  }).toList();
});

/// Daftar tunggakan yang murni terkena penalty
final daftarTunggakanProvider = Provider<List<StatusRumahInfo>>((ref) {
  return ref.watch(statusRumahProvider).where((s) => s.hasTunggakan).toList();
});

/// Jadwal Ronda Hari Ini
final jadwalRondaHariIniProvider = Provider<List<JadwalRondaModel>>((ref) {
  final today = ref.watch(todayProvider).value ?? DateTime.now();
  final dayOfWeek = today.weekday; // 1 = Senin, 7 = Minggu
  
  return DummyData.jadwalRonda.where((j) => j.hari == dayOfWeek).toList();
});
