import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimpitan_digital/core/constants/app_colors.dart';
import 'package:jimpitan_digital/core/constants/app_strings.dart';
import 'package:jimpitan_digital/shared/models/rumah_model.dart';
import 'package:jimpitan_digital/features/petugas/presentation/providers/sesi_ronda_notifier.dart';
import 'package:jimpitan_digital/features/petugas/presentation/providers/petugas_providers.dart';

class ScanQrPage extends ConsumerStatefulWidget {
  const ScanQrPage({super.key});

  @override
  ConsumerState<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends ConsumerState<ScanQrPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanAnim;
  late Animation<double> _scanLine;

  @override
  void initState() {
    super.initState();
    _scanAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanLine = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanAnim, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sesi = ref.watch(sesiRondaNotifierProvider);
    final rumahList = ref.watch(petugasRumahListProvider);

    if (!sesi.hasSesiAktif) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.scanQr)),
        body: const Center(
          child: Text('Mulai sesi ronda terlebih dahulu.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Scan QR — ${sesi.activeSesi!.rt}'),
      ),
      body: Column(
        children: [
          // ── Scanner frame ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(32),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.primary, width: 3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Container(
                        color: Colors.black87,
                        child: const Center(
                          child: Icon(
                            Icons.qr_code_rounded,
                            color: Colors.white24,
                            size: 80,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Animated scan line
                  AnimatedBuilder(
                    animation: _scanLine,
                    builder: (_, _) {
                      return Positioned(
                        top: _scanLine.value *
                            (MediaQuery.of(context).size.width - 64 - 16),
                        left: 8,
                        right: 8,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.primary,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Corner decorations
                  ..._buildCorners(),
                ],
              ),
            ),
          ),

          // ── Instruksi ──────────────────────────────────────────────────
          const Text(
            'Mode Demo: Pilih rumah untuk mensimulasikan scan',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // ── List rumah untuk dipilih ───────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      children: [
                        const Text(
                          'Daftar Rumah',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        _BadgeCount(
                          text:
                              '${sesi.scannedRumahIds.length}/${rumahList.length} discan',
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      itemCount: rumahList.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final rumah = rumahList[i];
                        final sudahDiscan =
                            sesi.scannedRumahIds.contains(rumah.id);
                        return _RumahScanCard(
                          rumah: rumah,
                          sudahDiscan: sudahDiscan,
                          onScan: () => _showScanModal(context, ref, rumah),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCorners() {
    const size = 20.0;
    const thickness = 3.0;
    final color = AppColors.primaryLight;

    Widget corner(AlignmentGeometry align, bool flipX, bool flipY) {
      return Align(
        alignment: align,
        child: Transform.scale(
          scaleX: flipX ? -1 : 1,
          scaleY: flipY ? -1 : 1,
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _CornerPainter(color: color, thickness: thickness),
            ),
          ),
        ),
      );
    }

    return [
      corner(Alignment.topLeft, false, false),
      corner(Alignment.topRight, true, false),
      corner(Alignment.bottomLeft, false, true),
      corner(Alignment.bottomRight, true, true),
    ];
  }

  void _showScanModal(
      BuildContext context, WidgetRef ref, RumahModel rumah) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ScanModal(rumah: rumah),
    );
  }
}

// ── Scan Modal ──────────────────────────────────────────────────────────────

class _ScanModal extends ConsumerStatefulWidget {
  final RumahModel rumah;

  const _ScanModal({required this.rumah});

  @override
  ConsumerState<_ScanModal> createState() => _ScanModalState();
}

class _ScanModalState extends ConsumerState<_ScanModal> {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Rumah info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.petugasColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.home_rounded,
                    color: AppColors.petugasColor, size: 28),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.rumah.nomorRumah,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    widget.rumah.namaKepalaKeluarga,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  Text(
                    widget.rumah.alamat,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Camera/QR area
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _scanned ? AppColors.success : AppColors.textDisabled,
                width: 2,
              ),
            ),
            child: _scanned
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_enhance_rounded,
                          color: Colors.white54, size: 60),
                      const SizedBox(height: 8),
                      Text(
                        'Foto akan tersimpan otomatis',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code_scanner_rounded,
                          color: AppColors.primary, size: 60),
                      const SizedBox(height: 8),
                      const Text(
                        'Tekan "Scan Berhasil" untuk\nmelanjutkan ke kamera',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 20),

          // Action button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                if (!_scanned) {
                  setState(() => _scanned = true);
                } else {
                  // Simpan jimpitan
                  final fotoUrl =
                      'https://picsum.photos/seed/${widget.rumah.id}${DateTime.now().millisecond}/400/300';
                  ref
                      .read(sesiRondaNotifierProvider.notifier)
                      .recordJimpitan(widget.rumah, fotoUrl);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '✅ ${widget.rumah.nomorRumah} berhasil dicatat!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              icon: Icon(_scanned
                  ? Icons.camera_alt_rounded
                  : Icons.qr_code_rounded),
              label: Text(
                _scanned ? 'Ambil Foto Bukti' : 'Scan Berhasil!',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _scanned ? AppColors.petugasColor : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subwidgets ───────────────────────────────────────────────────────────────

class _RumahScanCard extends StatelessWidget {
  final RumahModel rumah;
  final bool sudahDiscan;
  final VoidCallback onScan;

  const _RumahScanCard({
    required this.rumah,
    required this.sudahDiscan,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: sudahDiscan
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.textDisabled.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: sudahDiscan
                  ? AppColors.success.withValues(alpha: 0.12)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: sudahDiscan
                  ? const Icon(Icons.check_rounded,
                      color: AppColors.success, size: 22)
                  : Text(
                      rumah.nomorRumah,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: AppColors.textSecondary,
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
                  rumah.namaKepalaKeluarga,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  rumah.alamat,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (sudahDiscan)
            _BadgeCount(text: 'Discan', color: AppColors.success)
          else
            TextButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
              label: const Text('SCAN'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
        ],
      ),
    );
  }
}

class _BadgeCount extends StatelessWidget {
  final String text;
  final Color color;

  const _BadgeCount({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;

  _CornerPainter({required this.color, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
