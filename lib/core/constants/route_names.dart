/// Named routes untuk go_router
class RouteNames {
  RouteNames._();

  // Auth
  static const String login = '/';

  // Petugas (nested di bawah /petugas/dashboard)
  static const String petugasDashboard = '/petugas/dashboard';
  static const String petugasScanQr = 'scan-qr';
  static const String petugasListRumah = 'list-rumah';

  // Warga
  static const String wargaDashboard = '/warga/dashboard';
  static const String wargaRiwayatDetail = '/warga/riwayat/detail';

  // Bendahara
  static const String bendaharaDashboard = '/bendahara/dashboard';
  static const String bendaharaLaporan = '/bendahara/laporan';
  static const String bendaharaLaporanDetail = '/bendahara/laporan/detail';
}
