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
import 'package:jimpitan_digital/features/bendahara/presentation/providers/bendahara_providers.dart';

class BendaharaDashboardPage extends ConsumerWidget {
  const BendaharaDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final stats = ref.watch(bendaharaDashboardStatsProvider);
    final jimpitanHariIni = ref.watch(jimpitanHariIniAllProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: JimpitanAppBar(
        title: 'Dashboard Bendahara',
        role: AppStrings.roleBendahara,
        roleColor: AppColors.bendaharaColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.description_rounded,
                color: AppColors.textSecondary),
            tooltip: 'Laporan',
            onPressed: () => context.push(RouteNames.bendaharaLaporan),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Summary Card ──────────────────────────────────────────────
            _buildSummaryCard(user?.nama ?? 'Bendahara', stats),
            const SizedBox(height: 20),
            // ── Stat Row ──────────────────────────────────────────────────
            _buildStatRow(stats),
            const SizedBox(height: 24),
            // ── Quick actions ─────────────────────────────────────────────
            const Text(
              'Aksi Cepat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _ActionTile(
              label: 'Laporan Lengkap',
              icon: Icons.description_outlined,
              color: AppColors.petugasColor,
              onTap: () => context.push(RouteNames.bendaharaLaporan),
            ),
            const SizedBox(height: 24),
            // ── Aktivitas hari ini ────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aktivitas Hari Ini',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${jimpitanHariIni.length} tercatat',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (jimpitanHariIni.isEmpty)
              _emptyState('Belum ada aktivitas hari ini')
            else
              ...jimpitanHariIni.take(10).map(_buildJimpitanRow),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String nama, BendaharaStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selamat datang, $nama!',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${stats.totalDiambilBulanIni}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 6, left: 6),
                child: Text(
                  ' pengambilan bulan ini',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SummaryChip(
                  icon: Icons.home_rounded,
                  text: '${stats.totalRumah} Rumah'),
              const SizedBox(width: 14),
              _SummaryChip(
                  icon: Icons.check_rounded,
                  text: '${stats.totalDiambilHariIni} Hari Ini'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BendaharaStats stats) {
    return Row(
      children: [
        _StatBox(
          value: '${stats.totalDiambilHariIni}',
          label: 'Diambil Hari Ini',
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.success,
        ),
        const SizedBox(width: 12),
        _StatBox(
          value: '${stats.totalKosongHariIni}',
          label: 'Kosong Hari Ini',
          icon: Icons.cancel_outlined,
          color: AppColors.error,
        ),
        const SizedBox(width: 12),
        _StatBox(
          value: '${stats.totalRumah}',
          label: 'Total Rumah',
          icon: Icons.home_outlined,
          color: AppColors.petugasColor,
        ),
      ],
    );
  }

  Widget _buildJimpitanRow(JimpitanModel j) {
    final isDiambil = j.status == JimpitanStatus.diambil;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
            isDiambil ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: isDiambil ? AppColors.success : AppColors.error,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${j.nomorRumah} — ${j.namaKepalaKeluarga}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
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
            Icon(Icons.inbox_rounded, size: 44, color: AppColors.textDisabled),
            const SizedBox(height: 8),
            Text(msg, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ── Subwidgets ────────────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SummaryChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                )),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    )),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textDisabled),
            ],
          ),
        ),
      ),
    );
  }
}
