import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimpitan_digital/shared/models/rumah_model.dart';
import 'package:jimpitan_digital/shared/models/jimpitan_model.dart';
import 'package:jimpitan_digital/core/data/dummy_data.dart';
import 'package:jimpitan_digital/features/auth/presentation/providers/auth_provider.dart';
import 'jimpitan_list_notifier.dart';

/// Daftar rumah berdasarkan RT (family provider)
final rumahByRtProvider = Provider.family<List<RumahModel>, String>(
  (ref, rt) => DummyData.semuaRumah.where((r) => r.rt == rt).toList(),
);

/// Rumah milik petugas yang sedang login (berdasarkan RT)
final petugasRumahListProvider = Provider<List<RumahModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(rumahByRtProvider(user.rt));
});

/// Jimpitan hari ini untuk RT petugas yang sedang login
final jimpitanHariIniByRtProvider = Provider<List<JimpitanModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final today = DateTime.now();
  final allJimpitan = ref.watch(jimpitanListNotifierProvider);
  return allJimpitan
      .where((j) =>
          j.tanggal.year == today.year &&
          j.tanggal.month == today.month &&
          j.tanggal.day == today.day &&
          DummyData.semuaRumah
              .where((r) => r.rt == user.rt)
              .any((r) => r.id == j.rumahId))
      .toList();
});
