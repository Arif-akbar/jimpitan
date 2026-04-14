import 'package:go_router/go_router.dart';
import 'package:jimpitan_digital/features/auth/presentation/pages/login_page.dart';
import 'package:jimpitan_digital/features/petugas/presentation/pages/petugas_dashboard_page.dart';
import 'package:jimpitan_digital/features/petugas/presentation/pages/scan_qr_page.dart';
import 'package:jimpitan_digital/features/petugas/presentation/pages/list_rumah_page.dart';
import 'package:jimpitan_digital/features/warga/presentation/pages/warga_dashboard_page.dart';
import 'package:jimpitan_digital/features/warga/presentation/pages/riwayat_detail_page.dart';
import 'package:jimpitan_digital/features/bendahara/presentation/pages/bendahara_dashboard_page.dart';
import 'package:jimpitan_digital/features/bendahara/presentation/pages/laporan_page.dart';
import 'package:jimpitan_digital/features/bendahara/presentation/pages/laporan_detail_page.dart';
import 'package:jimpitan_digital/shared/models/jimpitan_model.dart';
import 'package:jimpitan_digital/features/bendahara/presentation/providers/bendahara_providers.dart';
import 'package:jimpitan_digital/core/constants/route_names.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.login,
  routes: [
    // ── Auth ──────────────────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.login,
      name: RouteNames.login,
      builder: (context, state) => const LoginPage(),
    ),

    // ── Petugas (nested routes) ───────────────────────────────────────────
    GoRoute(
      path: RouteNames.petugasDashboard,
      name: RouteNames.petugasDashboard,
      builder: (context, state) => const PetugasDashboardPage(),
      routes: [
        GoRoute(
          path: RouteNames.petugasScanQr,
          name: RouteNames.petugasScanQr,
          builder: (context, state) => const ScanQrPage(),
        ),
        GoRoute(
          path: RouteNames.petugasListRumah,
          name: RouteNames.petugasListRumah,
          builder: (context, state) => const ListRumahPage(),
        ),
      ],
    ),

    // ── Warga ─────────────────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.wargaDashboard,
      name: RouteNames.wargaDashboard,
      builder: (context, state) => const WargaDashboardPage(),
    ),
    GoRoute(
      path: RouteNames.wargaRiwayatDetail,
      name: RouteNames.wargaRiwayatDetail,
      builder: (context, state) {
        final jimpitan = state.extra as JimpitanModel;
        return RiwayatDetailPage(jimpitan: jimpitan);
      },
    ),

    // ── Bendahara ─────────────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.bendaharaDashboard,
      name: RouteNames.bendaharaDashboard,
      builder: (context, state) => const BendaharaDashboardPage(),
    ),
    GoRoute(
      path: RouteNames.bendaharaLaporan,
      name: RouteNames.bendaharaLaporan,
      builder: (context, state) => const LaporanPage(),
    ),
    GoRoute(
      path: RouteNames.bendaharaLaporanDetail,
      name: RouteNames.bendaharaLaporanDetail,
      builder: (context, state) {
        final laporan = state.extra as LaporanHarian;
        return LaporanDetailPage(laporan: laporan);
      },
    ),
  ],
);
