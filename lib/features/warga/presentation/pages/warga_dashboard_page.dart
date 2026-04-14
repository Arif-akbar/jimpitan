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
import 'package:jimpitan_digital/features/warga/presentation/providers/warga_providers.dart';

class WargaDashboardPage extends ConsumerStatefulWidget {
  const WargaDashboardPage({super.key});

  @override
  ConsumerState<WargaDashboardPage> createState() => _WargaDashboardPageState();
}

class _WargaDashboardPageState extends ConsumerState<WargaDashboardPage> {
  bool _notifClosed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotifikasi();
    });
  }

  void _checkNotifikasi() {
    if (!mounted || _notifClosed) return;
    final newJimpitan = ref.read(hasNewJimpitanProvider);
    if (newJimpitan != null) {
      _showNotifikasiDialog(newJimpitan);
    }
  }

  void _showNotifikasiDialog(JimpitanModel j) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications_active_rounded,
                color: AppColors.primary),
            SizedBox(width: 8),
            Text('Notifikasi Jimpitan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Petugas telah mengambil jimpitan di rumah Anda!',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _InfoRow(
                icon: Icons.person_rounded,
                label: 'Petugas',
                value: j.petugasNama ?? '-'),
            const SizedBox(height: 6),
            _InfoRow(
                icon: Icons.access_time_rounded,
                label: 'Waktu',
                value: j.waktuPengambilan != null
                    ? DateFormat('HH:mm').format(j.waktuPengambilan!)
                    : '-'),
            const SizedBox(height: 6),
            _InfoRow(
                icon: Icons.location_on_rounded,
                label: 'Lokasi',
                value: j.lokasi ?? '-'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() => _notifClosed = true);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('OK, Terima Kasih!',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final myRumah = ref.watch(myRumahProvider);
    final history = ref.watch(myJimpitanHistoryProvider);
    final todayStatus = ref.watch(todayJimpitanStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: JimpitanAppBar(
        title: myRumah?.nomorRumah ?? 'Dashboard',
        role: AppStrings.roleWarga,
        roleColor: AppColors.wargaColor,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _notifClosed = false;
          _checkNotifikasi();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Status Card ──
              _buildStatusCard(user?.nama ?? '-', todayStatus),
              const SizedBox(height: 20),
              // ── Rumah info ──
              if (myRumah != null) _buildRumahInfo(myRumah.alamat),
              const SizedBox(height: 24),
              // ── Riwayat ──
              const Text(
                'Riwayat Jimpitan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (history.isEmpty)
                _emptyState('Belum ada riwayat jimpitan')
              else
                ...history
                    .take(20)
                    .map((j) => _buildHistoryCard(context, j)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(String nama, JimpitanStatus? status) {
    Color cardColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case JimpitanStatus.diambil:
        cardColor = AppColors.success;
        statusText = '✅ Sudah Diambil Hari Ini';
        statusIcon = Icons.check_circle_rounded;
        break;
      case JimpitanStatus.kosong:
        cardColor = AppColors.error;
        statusText = '❌ Tidak Ada (Kosong)';
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        cardColor = AppColors.wargaColor;
        statusText = '⏳ Belum Ada Kabar Hari Ini';
        statusIcon = Icons.hourglass_empty_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardColor, cardColor.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Halo, $nama!',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(statusIcon, color: Colors.white38, size: 44),
        ],
      ),
    );
  }

  Widget _buildRumahInfo(String alamat) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.home_rounded, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              alamat,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, JimpitanModel j) {
    final isDiambil = j.status == JimpitanStatus.diambil;
    return GestureDetector(
      onTap: () => context.push(RouteNames.wargaRiwayatDetail, extra: j),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
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
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, d MMM yyyy', 'id_ID').format(j.tanggal),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  if (isDiambil && j.petugasNama != null)
                    Text('Petugas: ${j.petugasNama}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDiambil
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    j.status.label,
                    style: TextStyle(
                      color: isDiambil ? AppColors.success : AppColors.error,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isDiambil)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.chevron_right_rounded,
                        color: AppColors.textDisabled, size: 18),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.history_rounded, size: 48, color: AppColors.textDisabled),
            const SizedBox(height: 8),
            Text(msg, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
        Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600))),
      ],
    );
  }
}
