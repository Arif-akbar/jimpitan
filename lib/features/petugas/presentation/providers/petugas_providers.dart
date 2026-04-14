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

class PetugasRumahListNotifier extends StateNotifier<List<RumahModel>> {
  PetugasRumahListNotifier(super.state);

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final newState = List<RumahModel>.from(state);
    final item = newState.removeAt(oldIndex);
    newState.insert(newIndex, item);
    state = newState;
  }
}

/// Rumah milik petugas yang sedang login (berdasarkan RT) dengan fitur Reorder
final petugasRumahListProvider = StateNotifierProvider<PetugasRumahListNotifier, List<RumahModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return PetugasRumahListNotifier([]);
  // Ambil data utuh jika ini inisialisasi awal
  final initialList = DummyData.semuaRumah.where((r) => r.rt == user.rt).toList();
  return PetugasRumahListNotifier(initialList);
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
