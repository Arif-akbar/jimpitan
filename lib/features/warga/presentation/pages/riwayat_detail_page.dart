import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jimpitan_digital/core/constants/app_colors.dart';
import 'package:jimpitan_digital/shared/models/jimpitan_model.dart';

class RiwayatDetailPage extends StatelessWidget {
  final JimpitanModel jimpitan;

  const RiwayatDetailPage({super.key, required this.jimpitan});

  @override
  Widget build(BuildContext context) {
    final isDiambil = jimpitan.status == JimpitanStatus.diambil;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Jimpitan'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Foto bukti ──
            _buildFotoSection(isDiambil),
            // ── Detail info ──
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status badge
                  Row(
                    children: [
                      _StatusBadge(isDiambil: isDiambil),
                      const Spacer(),
                      Text(
                        DateFormat('d MMMM yyyy', 'id_ID')
                            .format(jimpitan.tanggal),
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Info card
                  _DetailCard(children: [
                    _DetailRow(
                      icon: Icons.home_rounded,
                      label: 'Rumah',
                      value: '${jimpitan.nomorRumah} — ${jimpitan.namaKepalaKeluarga}',
                    ),
                    const Divider(height: 20),
                    _DetailRow(
                      icon: Icons.person_rounded,
                      label: 'Petugas',
                      value: jimpitan.petugasNama ?? '-',
                    ),
                    const Divider(height: 20),
                    _DetailRow(
                      icon: Icons.access_time_rounded,
                      label: 'Waktu',
                      value: jimpitan.waktuPengambilan != null
                          ? DateFormat('HH:mm, d MMM yyyy')
                              .format(jimpitan.waktuPengambilan!)
                          : '-',
                    ),
                    const Divider(height: 20),
                    _DetailRow(
                      icon: Icons.location_on_rounded,
                      label: 'Lokasi GPS',
                      value: jimpitan.lokasi ?? '-',
                    ),
                    const Divider(height: 20),
                    _DetailRow(
                      icon: Icons.assignment_rounded,
                      label: 'Status',
                      value: jimpitan.status.label,
                      valueColor:
                          isDiambil ? AppColors.success : AppColors.error,
                    ),
                  ]),
                  const SizedBox(height: 16),
                  // Transparansi note
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_rounded,
                            color: AppColors.primary, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Data ini telah tercatat secara otomatis dan tidak dapat diubah.',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFotoSection(bool isDiambil) {
    if (!isDiambil || jimpitan.fotoUrl == null) {
      return Container(
        height: 220,
        color: Colors.grey.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported_rounded,
                  size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text('Tidak ada foto bukti',
                  style: TextStyle(color: Colors.grey.shade500)),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Image.network(
          jimpitan.fotoUrl!,
          width: double.infinity,
          height: 250,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            height: 250,
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.broken_image_rounded,
                  size: 48, color: Colors.grey),
            ),
          ),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Container(
              height: 250,
              color: Colors.grey.shade100,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
        ),
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text('Foto Bukti',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isDiambil;

  const _StatusBadge({required this.isDiambil});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isDiambil
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDiambil
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.error.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDiambil ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: isDiambil ? AppColors.success : AppColors.error,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            isDiambil ? 'Berhasil Diambil' : 'Tidak Ada (Kosong)',
            style: TextStyle(
              color: isDiambil ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final List<Widget> children;

  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
