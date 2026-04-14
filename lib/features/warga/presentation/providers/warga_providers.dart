import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimpitan_digital/shared/models/rumah_model.dart';
import 'package:jimpitan_digital/shared/models/jimpitan_model.dart';
import 'package:jimpitan_digital/core/data/dummy_data.dart';
import 'package:jimpitan_digital/features/auth/presentation/providers/auth_provider.dart';
import 'package:jimpitan_digital/features/petugas/presentation/providers/jimpitan_list_notifier.dart';

/// Rumah milik warga yang sedang login
final myRumahProvider = Provider<RumahModel?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user?.rumahId == null) return null;
  return DummyData.semuaRumah
      .where((r) => r.id == user!.rumahId)
      .firstOrNull;
});

/// Seluruh riwayat jimpitan untuk rumah warga (diurutkan terbaru)
final myJimpitanHistoryProvider = Provider<List<JimpitanModel>>((ref) {
  final myRumah = ref.watch(myRumahProvider);
  if (myRumah == null) return [];
  final all = ref.watch(jimpitanListNotifierProvider);
  final filtered = all.where((j) => j.rumahId == myRumah.id).toList()
    ..sort((a, b) => b.tanggal.compareTo(a.tanggal));
  return filtered;
});

/// Status jimpitan hari ini untuk rumah warga
final todayJimpitanStatusProvider = Provider<JimpitanStatus?>((ref) {
  final history = ref.watch(myJimpitanHistoryProvider);
  final today = DateTime.now();
  final todayRecord = history.where((j) =>
      j.tanggal.year == today.year &&
      j.tanggal.month == today.month &&
      j.tanggal.day == today.day).firstOrNull;
  return todayRecord?.status;
});

/// Apakah ada jimpitan baru (max 5 menit lalu) → untuk simulasi notifikasi
final hasNewJimpitanProvider = Provider<JimpitanModel?>((ref) {
  final history = ref.watch(myJimpitanHistoryProvider);
  if (history.isEmpty) return null;
  final latest = history.first;
  if (latest.waktuPengambilan == null) return null;
  final diff = DateTime.now().difference(latest.waktuPengambilan!);
  if (diff.inMinutes < 5) return latest;
  return null;
});
