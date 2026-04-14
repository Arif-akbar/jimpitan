import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimpitan_digital/core/constants/app_colors.dart';
import 'package:jimpitan_digital/core/constants/app_strings.dart';
import 'package:jimpitan_digital/shared/models/jimpitan_model.dart';
import 'package:jimpitan_digital/shared/widgets/jimpitan_app_bar.dart';
import 'package:jimpitan_digital/features/petugas/presentation/providers/sesi_ronda_notifier.dart';
import 'package:jimpitan_digital/features/petugas/presentation/providers/petugas_providers.dart';

class ListRumahPage extends ConsumerWidget {
  const ListRumahPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rumahList = ref.watch(petugasRumahListProvider);
    final sesi = ref.watch(sesiRondaNotifierProvider);
    final scanned = sesi.scannedRumahIds;

    final diambil = scanned.length;
    final kosong = sesi.jimpitanSesiIni
        .where((j) => j.status == JimpitanStatus.kosong)
        .length;
    final belum = rumahList.length - diambil - kosong;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: JimpitanAppBar(
        title: AppStrings.listRumah,
        role: AppStrings.rolePetugas,
        roleColor: AppColors.petugasColor,
      ),
      body: Column(
        children: [
          // ── Summary bar ──────────────────────────────────────────────────
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _StatusDot(count: diambil, label: 'Discan', color: AppColors.success),
                const SizedBox(width: 16),
                _StatusDot(count: kosong, label: 'Kosong', color: AppColors.error),
                const SizedBox(width: 16),
                _StatusDot(count: belum < 0 ? 0 : belum, label: 'Belum', color: AppColors.textSecondary),
                const Spacer(),
                Text(
                  '${rumahList.length} Rumah',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // ── Progress bar ──────────────────────────────────────────────────
          if (sesi.hasSesiAktif)
            LinearProgressIndicator(
              value: rumahList.isEmpty ? 0 : scanned.length / rumahList.length,
              backgroundColor: AppColors.background,
              color: AppColors.primary,
              minHeight: 4,
            ),
          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rumahList.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final rumah = rumahList[i];
                // Cek apakah rumah ini ada di sesi saat ini
                final jimpitanSesiIni = sesi.jimpitanSesiIni
                    .where((j) => j.rumahId == rumah.id)
                    .firstOrNull;
                final statusSesiIni = jimpitanSesiIni?.status;

                return _HouseCard(
                  nomorRumah: rumah.nomorRumah,
                  namaKK: rumah.namaKepalaKeluarga,
                  alamat: rumah.alamat,
                  status: statusSesiIni,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _StatusDot(
      {required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '$count $label',
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _HouseCard extends StatelessWidget {
  final String nomorRumah;
  final String namaKK;
  final String alamat;
  final JimpitanStatus? status;

  const _HouseCard({
    required this.nomorRumah,
    required this.namaKK,
    required this.alamat,
    this.status,
  });

  Color get _color {
    switch (status) {
      case JimpitanStatus.diambil:
        return AppColors.success;
      case JimpitanStatus.kosong:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _icon {
    switch (status) {
      case JimpitanStatus.diambil:
        return Icons.check_circle_rounded;
      case JimpitanStatus.kosong:
        return Icons.cancel_rounded;
      default:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  String get _statusLabel {
    switch (status) {
      case JimpitanStatus.diambil:
        return 'Discan';
      case JimpitanStatus.kosong:
        return 'Kosong';
      default:
        return 'Belum';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                nomorRumah,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _color,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(namaKK,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    )),
                Text(alamat,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Row(
            children: [
              Icon(_icon, color: _color, size: 16),
              const SizedBox(width: 4),
              Text(_statusLabel,
                  style: TextStyle(
                    color: _color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
