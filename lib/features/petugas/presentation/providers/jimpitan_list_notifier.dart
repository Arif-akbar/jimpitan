import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimpitan_digital/shared/models/jimpitan_model.dart';
import 'package:jimpitan_digital/core/data/dummy_data.dart';

/// In-memory store untuk semua record jimpitan.
/// Digunakan oleh semua fitur (petugas, warga, bendahara).
class JimpitanListNotifier extends StateNotifier<List<JimpitanModel>> {
  JimpitanListNotifier() : super(DummyData.generateHistoricalJimpitan());

  void addJimpitan(JimpitanModel jimpitan) {
    state = [...state, jimpitan];
  }

  void addAll(List<JimpitanModel> list) {
    state = [...state, ...list];
  }

  void updateJimpitan(JimpitanModel updated) {
    state = [
      for (final j in state)
        if (j.id == updated.id) updated else j,
    ];
  }
}

final jimpitanListNotifierProvider =
    StateNotifierProvider<JimpitanListNotifier, List<JimpitanModel>>(
  (ref) => JimpitanListNotifier(),
);
