import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimpitan_digital/shared/models/keuangan_model.dart';
import 'package:jimpitan_digital/core/data/dummy_data.dart';
import 'package:uuid/uuid.dart';

class KeuanganNotifier extends StateNotifier<List<KeuanganModel>> {
  KeuanganNotifier() : super(DummyData.generateKeuanganAwal());

  void addCatatan(TipeKeuangan tipe, int nominal, String keterangan) {
    final newCatatan = KeuanganModel(
      id: const Uuid().v4(),
      tipe: tipe,
      nominal: nominal,
      keterangan: keterangan,
      tanggal: DateTime.now(),
    );
    state = [newCatatan, ...state];
  }
}

final keuanganNotifierProvider = StateNotifierProvider<KeuanganNotifier, List<KeuanganModel>>((ref) {
  return KeuanganNotifier();
});

/// Rekap total pemasukan, pengeluaran, dan saldo
final rekapKeuanganProvider = Provider<Map<String, int>>((ref) {
  final data = ref.watch(keuanganNotifierProvider);
  int pemasukan = 0;
  int pengeluaran = 0;

  for (final item in data) {
    if (item.tipe == TipeKeuangan.pemasukan) {
      pemasukan += item.nominal;
    } else {
      pengeluaran += item.nominal;
    }
  }

  return {
    'pemasukan': pemasukan,
    'pengeluaran': pengeluaran,
    'saldo': pemasukan - pengeluaran,
  };
});
