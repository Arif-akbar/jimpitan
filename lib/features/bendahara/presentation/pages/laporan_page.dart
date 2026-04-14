import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jimpitan_digital/core/constants/app_colors.dart';
import 'package:jimpitan_digital/core/constants/route_names.dart';
import 'package:jimpitan_digital/shared/widgets/jimpitan_app_bar.dart';
import 'package:jimpitan_digital/features/bendahara/presentation/providers/bendahara_providers.dart';

class LaporanPage extends ConsumerWidget {
  const LaporanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final laporanList = ref.watch(laporanHarianProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: JimpitanAppBar(
        title: 'Laporan Harian',
        role: 'Bendahara',
        roleColor: AppColors.bendaharaColor,
      ),
      body: laporanList.isEmpty
          ? const Center(child: Text('Belum ada data laporan'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: laporanList.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final laporan = laporanList[i];
                return _LaporanCard(
                  laporan: laporan,
                  onTap: () => context.push(
                    RouteNames.bendaharaLaporanDetail,
                    extra: laporan,
                  ),
                );
              },
            ),
    );
  }
}

class _LaporanCard extends StatelessWidget {
  final LaporanHarian laporan;
  final VoidCallback onTap;

  const _LaporanCard({required this.laporan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pct = laporan.persentaseDiambil;
    final isToday = () {
      final t = DateTime.now();
      return laporan.tanggal.year == t.year &&
          laporan.tanggal.month == t.month &&
          laporan.tanggal.day == t.day;
    }();

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              DateFormat('EEEE', 'id_ID')
                                  .format(laporan.tanggal),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (isToday) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('Hari Ini',
                                    style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          DateFormat('d MMMM yyyy', 'id_ID')
                              .format(laporan.tanggal),
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${pct.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: pct >= 80
                          ? AppColors.success
                          : pct >= 50
                              ? AppColors.warning
                              : AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 6,
                  backgroundColor: AppColors.error.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(
                    pct >= 80 ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Chip(
                      count: laporan.totalDiambil,
                      label: 'Diambil',
                      color: AppColors.success),
                  const SizedBox(width: 10),
                  _Chip(
                      count: laporan.totalKosong,
                      label: 'Kosong',
                      color: AppColors.error),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textDisabled),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _Chip(
      {required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
