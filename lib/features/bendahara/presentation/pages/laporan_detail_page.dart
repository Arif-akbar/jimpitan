import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jimpitan_digital/core/constants/app_colors.dart';
import 'package:jimpitan_digital/shared/models/jimpitan_model.dart';
import 'package:jimpitan_digital/features/bendahara/presentation/providers/bendahara_providers.dart';

class LaporanDetailPage extends StatelessWidget {
  final LaporanHarian laporan;

  const LaporanDetailPage({super.key, required this.laporan});

  @override
  Widget build(BuildContext context) {
    final diambilList =
        laporan.records.where((j) => j.status == JimpitanStatus.diambil).toList();
    final kosongList =
        laporan.records.where((j) => j.status == JimpitanStatus.kosong).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          DateFormat('d MMMM yyyy', 'id_ID').format(laporan.tanggal),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header stats ──
            _buildHeaderStats(),
            const SizedBox(height: 24),
            // ── Berhasil Diambil ──
            _buildSection(
              title: 'Berhasil Diambil (${diambilList.length})',
              color: AppColors.success,
              items: diambilList,
            ),
            if (kosongList.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildSection(
                title: 'Kosong / Tidak Ada (${kosongList.length})',
                color: AppColors.error,
                items: kosongList,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStats() {
    final pct = laporan.persentaseDiambil;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: pct >= 80
              ? [AppColors.success, const Color(0xFF16A34A)]
              : [AppColors.warning, const Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE', 'id_ID').format(laporan.tanggal),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${pct.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8, left: 8),
                child: Text(
                  'berhasil diambil',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatPill(
                  label: '${laporan.totalDiambil} Diambil',
                  color: Colors.white),
              const SizedBox(width: 12),
              _StatPill(
                  label: '${laporan.totalKosong} Kosong',
                  color: Colors.white60),
              const SizedBox(width: 12),
              _StatPill(
                  label: '${laporan.totalRumah} Total',
                  color: Colors.white38),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Color color,
    required List<JimpitanModel> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...items.map((j) => _RecordCard(jimpitan: j, color: color)),
      ],
    );
  }
}

class _RecordCard extends StatelessWidget {
  final JimpitanModel jimpitan;
  final Color color;

  const _RecordCard({required this.jimpitan, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                jimpitan.nomorRumah,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jimpitan.namaKepalaKeluarga,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (jimpitan.petugasNama != null)
                  Text(
                    'Petugas: ${jimpitan.petugasNama}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          if (jimpitan.waktuPengambilan != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('HH:mm').format(jimpitan.waktuPengambilan!),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                if (jimpitan.fotoUrl != null)
                  const Icon(Icons.image_rounded,
                      size: 14, color: AppColors.textSecondary),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: TextStyle(
            color: color, fontSize: 13, fontWeight: FontWeight.w600));
  }
}
