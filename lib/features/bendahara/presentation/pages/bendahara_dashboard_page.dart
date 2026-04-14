import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jimpitan_digital/core/constants/app_colors.dart';
import 'package:jimpitan_digital/core/constants/app_strings.dart';
import 'package:jimpitan_digital/core/constants/route_names.dart';
import 'package:jimpitan_digital/shared/models/jimpitan_model.dart';
import 'package:jimpitan_digital/shared/models/jadwal_ronda_model.dart';
import 'package:jimpitan_digital/shared/widgets/jimpitan_app_bar.dart';
import 'package:jimpitan_digital/features/auth/presentation/providers/auth_provider.dart';
import 'package:jimpitan_digital/features/bendahara/presentation/providers/bendahara_providers.dart';
import 'package:jimpitan_digital/features/bendahara/presentation/providers/keuangan_notifier.dart';

class BendaharaDashboardPage extends ConsumerWidget {
  const BendaharaDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final stats = ref.watch(bendaharaDashboardStatsProvider);
    final jimpitanHariIni = ref.watch(jimpitanHariIniAllProvider);
    final keuanganInfo = ref.watch(rekapKeuanganProvider);
    
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: JimpitanAppBar(
        title: 'Dashboard Bendahara',
        role: AppStrings.roleBendahara,
        roleColor: AppColors.bendaharaColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.description_rounded, color: AppColors.textSecondary),
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
            _buildSummaryCard(user?.nama ?? 'Bendahara', stats, keuanganInfo, formatter),
            const SizedBox(height: 20),
            
            // ── Menu Cepat ─────────────────────────────────────────────
            _buildQuickActions(context),
            const SizedBox(height: 24),
            
            // ── Jadwal Petugas Hari Ini ──────────────────────────────────────────
            _buildJadwalPetugasSection(ref),
            const SizedBox(height: 24),

            // ── Rekap Pengambilan Per Petugas ─────────────────────────────────
            _buildRekapPetugasSection(ref, formatter),
            const SizedBox(height: 24),

            // ── Aktivitas Hari Ini ────────────────────────────────────────
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              ...jimpitanHariIni.take(5).map(_buildJimpitanRow),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String nama, BendaharaStats stats, Map<String, int> keuangan, NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.bendaharaColor, Color(0xFFC0CA33)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.bendaharaColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selamat bekerja, $nama!',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 12),
          const Text('Saldo Kas Total', style: TextStyle(color: Colors.white70, fontSize: 12)),
          Text(
            fmt.format(keuangan['saldo']),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _SummaryChip(icon: Icons.home_rounded, text: '${stats.totalRumah} Rumah'),
              const SizedBox(width: 14),
              _SummaryChip(icon: Icons.check_rounded, text: '${stats.totalDiambilHariIni} Scan Hari Ini'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Cepat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionTileSmall(
                label: 'Status Rumah',
                icon: Icons.house_rounded,
                color: AppColors.primary,
                onTap: () => context.push(RouteNames.bendaharaRumah),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTileSmall(
                label: 'Arus Kas',
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.success,
                onTap: () => context.push(RouteNames.bendaharaKeuangan),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ActionTileSmall(
          label: 'Laporan Jimpitan',
          icon: Icons.description_outlined,
          color: AppColors.petugasColor,
          onTap: () => context.push(RouteNames.bendaharaLaporan),
        ),
      ],
    );
  }

  Widget _buildJadwalPetugasSection(WidgetRef ref) {
    final jadwal = ref.watch(jadwalRondaHariIniProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: AppColors.textPrimary, size: 20),
            const SizedBox(width: 8),
            Text(
              jadwal.isNotEmpty ? 'Jadwal Ronda Hari Ini (${jadwal.first.namaHari})' : 'Jadwal Ronda Hari Ini',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (jadwal.isEmpty) _emptyState('Tidak ada jadwal hari ini'),
        ...jadwal.map((j) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  j.rt,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  j.petugasNames.join(', '),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildRekapPetugasSection(WidgetRef ref, NumberFormat fmt) {
    final rekap = ref.watch(rekapPetugasHariIniProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         const Row(
          children: [
            Icon(Icons.people_alt_rounded, color: AppColors.textPrimary, size: 20),
            SizedBox(width: 8),
            Text(
              'Setoran Petugas Hari Ini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (rekap.isEmpty) _emptyState('Belum ada setoran petugas'),
        ...rekap.map((r) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.person, color: AppColors.petugasColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.petugasName,
                      style: const TextStyle(
                         fontWeight: FontWeight.w700,
                         color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${r.totalDiambil} rumah discan',
                      style: const TextStyle(
                         fontSize: 12,
                         color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                fmt.format(r.totalUang),
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              )
            ],
          ),
        )),
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
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 36, color: AppColors.textDisabled),
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

class _ActionTileSmall extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionTileSmall({
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
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
