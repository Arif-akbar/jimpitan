import 'package:jimpitan_digital/shared/enums/user_role.dart';
import 'package:jimpitan_digital/shared/models/user_model.dart';
import 'package:jimpitan_digital/shared/models/rumah_model.dart';
import 'package:jimpitan_digital/shared/models/jimpitan_model.dart';
import 'package:jimpitan_digital/shared/models/jadwal_ronda_model.dart';
import 'package:jimpitan_digital/shared/models/keuangan_model.dart';

/// Semua data dummy/seed untuk Phase 2 (tanpa Firebase)
class DummyData {
  DummyData._();

  // ─── USERS ───────────────────────────────────────────────────────────────
  static const List<UserModel> users = [
    UserModel(
      id: 'u1',
      nama: 'Ahmad Zaini',
      email: 'ahmad@jimpitan.com',
      role: UserRole.petugas,
      rt: 'RT01',
    ),
    UserModel(
      id: 'u2',
      nama: 'Dodi Setiawan',
      email: 'dodi@jimpitan.com',
      role: UserRole.petugas,
      rt: 'RT02',
    ),
    UserModel(
      id: 'u3',
      nama: 'Budi Santoso',
      email: 'budi@jimpitan.com',
      role: UserRole.warga,
      rt: 'RT01',
      rumahId: 'r1',
    ),
    UserModel(
      id: 'u4',
      nama: 'Siti Aminah',
      email: 'siti@jimpitan.com',
      role: UserRole.warga,
      rt: 'RT01',
      rumahId: 'r2',
    ),
    UserModel(
      id: 'u5',
      nama: 'Hendra Wijaya',
      email: 'hendra@jimpitan.com',
      role: UserRole.bendahara,
      rt: 'ALL',
    ),
  ];

  // ─── RUMAH ───────────────────────────────────────────────────────────────
  static const List<RumahModel> semuaRumah = [
    // RT01
    RumahModel(id: 'r1', nomorRumah: 'A-01', namaKepalaKeluarga: 'Budi Santoso', alamat: 'Jl. Mawar No. 1, RT01', rt: 'RT01'),
    RumahModel(id: 'r2', nomorRumah: 'A-02', namaKepalaKeluarga: 'Siti Aminah', alamat: 'Jl. Mawar No. 2, RT01', rt: 'RT01'),
    RumahModel(id: 'r3', nomorRumah: 'A-03', namaKepalaKeluarga: 'Ahmad Fauzi', alamat: 'Jl. Mawar No. 3, RT01', rt: 'RT01'),
    RumahModel(id: 'r4', nomorRumah: 'A-04', namaKepalaKeluarga: 'Dewi Lestari', alamat: 'Jl. Mawar No. 4, RT01', rt: 'RT01'),
    RumahModel(id: 'r5', nomorRumah: 'A-05', namaKepalaKeluarga: 'Rudi Hartono', alamat: 'Jl. Mawar No. 5, RT01', rt: 'RT01'),
    RumahModel(id: 'r6', nomorRumah: 'A-06', namaKepalaKeluarga: 'Indah Sari', alamat: 'Jl. Mawar No. 6, RT01', rt: 'RT01'),
    // RT02
    RumahModel(id: 'r7', nomorRumah: 'B-01', namaKepalaKeluarga: 'Bambang Setiawan', alamat: 'Jl. Melati No. 1, RT02', rt: 'RT02'),
    RumahModel(id: 'r8', nomorRumah: 'B-02', namaKepalaKeluarga: 'Yuni Astuti', alamat: 'Jl. Melati No. 2, RT02', rt: 'RT02'),
    RumahModel(id: 'r9', nomorRumah: 'B-03', namaKepalaKeluarga: 'Komarudin', alamat: 'Jl. Melati No. 3, RT02', rt: 'RT02'),
    RumahModel(id: 'r10', nomorRumah: 'B-04', namaKepalaKeluarga: 'Wulandari', alamat: 'Jl. Melati No. 4, RT02', rt: 'RT02'),
    RumahModel(id: 'r11', nomorRumah: 'B-05', namaKepalaKeluarga: 'Supriadi', alamat: 'Jl. Melati No. 5, RT02', rt: 'RT02'),
    RumahModel(id: 'r12', nomorRumah: 'B-06', namaKepalaKeluarga: 'Rina Maharani', alamat: 'Jl. Melati No. 6, RT02', rt: 'RT02'),
  ];

  // ─── HISTORICAL JIMPITAN (7 hari terakhir untuk RT01) ────────────────────
  static List<JimpitanModel> generateHistoricalJimpitan() {
    final List<JimpitanModel> records = [];
    final now = DateTime.now();
    final rt01Rumah = semuaRumah.where((r) => r.rt == 'RT01').toList();

    for (int day = 7; day >= 1; day--) {
      final tanggal = now.subtract(Duration(days: day));
      final dateStr =
          '${tanggal.year}${tanggal.month.toString().padLeft(2, '0')}${tanggal.day.toString().padLeft(2, '0')}';
      final sesiId = 'sesi_hist_$dateStr';

      for (final rumah in rt01Rumah) {
        // Buat pola beragam: beberapa hari ada kosong
        final isDiambil = !(rumah.id == 'r5' && day.isEven) &&
            !(rumah.id == 'r3' && day == 3);

        records.add(JimpitanModel(
          id: 'j_${dateStr}_${rumah.id}',
          rumahId: rumah.id,
          nomorRumah: rumah.nomorRumah,
          namaKepalaKeluarga: rumah.namaKepalaKeluarga,
          sesiId: sesiId,
          tanggal: tanggal,
          status: isDiambil ? JimpitanStatus.diambil : JimpitanStatus.kosong,
          fotoUrl: isDiambil
              ? 'https://picsum.photos/seed/${rumah.id}$day/400/300'
              : null,
          waktuPengambilan: isDiambil
              ? DateTime(tanggal.year, tanggal.month, tanggal.day, 19, 30)
              : null,
          lokasi: isDiambil ? '-7.2575° S, 112.4521° E' : null,
          petugasId: 'u1',
          petugasNama: 'Ahmad Zaini',
        ));
      }
    }
    return records;
  }

  // Helper: cari user by role (ambil yang pertama)
  static UserModel getUserByRole(UserRole role) =>
      users.firstWhere((u) => u.role == role);

  // Helper: cari rumah by RT
  static List<RumahModel> getRumahByRt(String rt) =>
      semuaRumah.where((r) => r.rt == rt).toList();

  // ─── DATA KEUANGAN AWAL ──────────────────────────────────────────────────
  static List<KeuanganModel> generateKeuanganAwal() {
    return [
      KeuanganModel(
        id: 'k1',
        tipe: TipeKeuangan.pemasukan,
        nominal: 150000,
        keterangan: 'Hasil jimpitan minggu ke-1',
        tanggal: DateTime.now().subtract(const Duration(days: 7)),
      ),
      KeuanganModel(
        id: 'k2',
        tipe: TipeKeuangan.pengeluaran,
        nominal: 25000,
        keterangan: 'Beli kopi dan gula untuk pos kamling',
        tanggal: DateTime.now().subtract(const Duration(days: 5)),
      ),
      KeuanganModel(
        id: 'k3',
        tipe: TipeKeuangan.pemasukan,
        nominal: 175000,
        keterangan: 'Hasil jimpitan minggu ke-2',
        tanggal: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  // ─── JADWAL RONDA ────────────────────────────────────────────────────────
  static const List<JadwalRondaModel> jadwalRonda = [
    JadwalRondaModel(id: 'j1', hari: 1, rt: 'RT01', petugasNames: ['Ahmad Zaini', 'Dodi Setiawan']),
    JadwalRondaModel(id: 'j2', hari: 1, rt: 'RT02', petugasNames: ['Teduh', 'Tedi']),
    JadwalRondaModel(id: 'j3', hari: 2, rt: 'RT01', petugasNames: ['Heri', 'Joko']),
    JadwalRondaModel(id: 'j4', hari: 2, rt: 'RT02', petugasNames: ['Rudi', 'Bambang']),
    JadwalRondaModel(id: 'j5', hari: 3, rt: 'RT01', petugasNames: ['Santoso', 'Yudi']),
    JadwalRondaModel(id: 'j6', hari: 3, rt: 'RT02', petugasNames: ['Wawan', 'Sapto']),
    JadwalRondaModel(id: 'j7', hari: 4, rt: 'RT01', petugasNames: ['Ahmad Zaini', 'Toni']),
    JadwalRondaModel(id: 'j8', hari: 4, rt: 'RT02', petugasNames: ['Tono', 'Tini']),
    JadwalRondaModel(id: 'j9', hari: 5, rt: 'RT01', petugasNames: ['Bayu', 'Bagas']),
    JadwalRondaModel(id: 'j10', hari: 5, rt: 'RT02', petugasNames: ['Iwan', 'Rizal']),
    JadwalRondaModel(id: 'j11', hari: 6, rt: 'RT01', petugasNames: ['Surya', 'Dani']),
    JadwalRondaModel(id: 'j12', hari: 6, rt: 'RT02', petugasNames: ['Doni', 'Dika']),
    JadwalRondaModel(id: 'j13', hari: 7, rt: 'RT01', petugasNames: ['Arif', 'Eko']),
    JadwalRondaModel(id: 'j14', hari: 7, rt: 'RT02', petugasNames: ['Indra', 'Ikhsan']),
  ];
}
