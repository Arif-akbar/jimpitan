import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jimpitan_digital/core/constants/app_colors.dart';
import 'package:jimpitan_digital/core/constants/app_strings.dart';
import 'package:jimpitan_digital/core/constants/route_names.dart';
import 'package:jimpitan_digital/shared/models/jimpitan_model.dart';
import 'package:jimpitan_digital/shared/widgets/jimpitan_app_bar.dart';
import 'package:jimpitan_digital/features/auth/presentation/providers/auth_provider.dart';
import 'package:jimpitan_digital/features/petugas/presentation/providers/sesi_ronda_notifier.dart';
import 'package:jimpitan_digital/features/petugas/presentation/providers/petugas_providers.dart';

class PetugasDashboardPage extends ConsumerWidget {
  const PetugasDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final sesi = ref.watch(sesiRondaNotifierProvider);
    final jimpitanHariIni = ref.watch(jimpitanHariIniByRtProvider);

    // Tampilkan summary dialog setelah sesi selesai
    if (sesi.showSummary) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSummaryDialog(context, ref, sesi);
      });
    }

    final diambil =
        jimpitanHariIni.where((j) => j.status == JimpitanStatus.diambil).length;
    final kosong =
        jimpitanHariIni.where((j) => j.status == JimpitanStatus.kosong).length;
    final totalRumah = ref.watch(petugasRumahListProvider).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: JimpitanAppBar(
        title: 'Dashboard ${user?.rt ?? ''}',
        role: AppStrings.rolePetugas,
        roleColor: AppColors.petugasColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Selamat datang ──
            _buildWelcomeCard(user?.nama ?? '-', sesi),
            const SizedBox(height: 20),
            // ── Statistik ──
            _buildStatRow(diambil, kosong, totalRumah),
            const SizedBox(height: 24),
            // ── Aksi ──
            if (!sesi.hasSesiAktif) ...[
              _bigButton(
                label: AppStrings.mulaiRonda,
                icon: Icons.play_circle_outline_rounded,
                color: AppColors.primary,
                onTap: () {
                  if (user != null) {
                    ref.read(sesiRondaNotifierProvider.notifier).startSesi(user);
                  }
                },
              ),
            ] else ...[
              _bigButton(
                label: AppStrings.scanQr,
                icon: Icons.qr_code_scanner_rounded,
                color: AppColors.petugasColor,
                onTap: () => context.goNamed(RouteNames.petugasScanQr),
              ),
              const SizedBox(height: 12),
              _bigButton(
                label: AppStrings.listRumah,
                icon: Icons.format_list_bulleted_rounded,
                color: AppColors.accent,
                subtitle: '${sesi.totalDiambil} discan dari $totalRumah rumah',
                onTap: () => context.goNamed(RouteNames.petugasListRumah),
              ),
              const SizedBox(height: 12),
              _bigButton(
                label: AppStrings.selesaiRonda,
                icon: Icons.stop_circle_outlined,
                color: AppColors.error,
                onTap: () => _konfirmasiSelesai(context, ref),
              ),
            ],
            const SizedBox(height: 28),
            // ── Aktivitas hari ini ──
            const Text(
              'Aktivitas Hari Ini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (jimpitanHariIni.isEmpty)
              _emptyState('Belum ada aktivitas hari ini')
            else
              ...jimpitanHariIni.take(5).map(_buildAktivitasCard),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String nama, SesiRondaState sesi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang, $nama!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sesi.hasSesiAktif
                      ? '🟢 Sesi Ronda Aktif'
                      : '⚪ Belum ada sesi aktif',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.directions_walk_rounded,
              color: Colors.white54, size: 40),
        ],
      ),
    );
  }

  Widget _buildStatRow(int diambil, int kosong, int total) {
    return Row(
      children: [
        _StatCard(value: '$diambil', label: 'Diambil', color: AppColors.success),
        const SizedBox(width: 10),
        _StatCard(value: '$kosong', label: 'Kosong', color: AppColors.error),
        const SizedBox(width: 10),
        _StatCard(value: '$total', label: 'Total', color: AppColors.petugasColor),
      ],
    );
  }

  Widget _bigButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        )),
                    if (subtitle != null)
                      Text(subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          )),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textDisabled),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAktivitasCard(JimpitanModel j) {
    final isDiambil = j.status == JimpitanStatus.diambil;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDiambil
              ? AppColors.success.withValues(alpha: 0.2)
              : AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isDiambil
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            color: isDiambil ? AppColors.success : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${j.nomorRumah} — ${j.namaKepalaKeluarga}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (j.waktuPengambilan != null)
            Text(
              DateFormat('HH:mm').format(j.waktuPengambilan!),
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 42, color: AppColors.textDisabled),
            const SizedBox(height: 8),
            Text(msg,
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  void _konfirmasiSelesai(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Selesai Ronda?'),
        content: const Text(
            'Rumah yang belum discan akan otomatis ditandai sebagai KOSONG.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(sesiRondaNotifierProvider.notifier).endSesi();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Selesai', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSummaryDialog(
      BuildContext context, WidgetRef ref, SesiRondaState sesi) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success),
            SizedBox(width: 8),
            Text('Ronda Selesai!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _summaryRow('✅ Total Diambil', '${sesi.totalDiambil} rumah',
                AppColors.success),
            const SizedBox(height: 8),
            _summaryRow('❌ Total Kosong', '${sesi.totalKosong} rumah',
                AppColors.error),
            const SizedBox(height: 8),
            _summaryRow(
              '🏠 Total Rumah',
              '${sesi.jimpitanSesiIni.length} rumah',
              AppColors.textSecondary,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(sesiRondaNotifierProvider.notifier).dismissSummary();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCard(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            Text(label,
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
