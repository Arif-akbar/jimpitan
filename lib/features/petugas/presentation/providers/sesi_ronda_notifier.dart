import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimpitan_digital/shared/models/user_model.dart';
import 'package:jimpitan_digital/shared/models/rumah_model.dart';
import 'package:jimpitan_digital/shared/models/jimpitan_model.dart';
import 'package:jimpitan_digital/shared/models/sesi_ronda_model.dart';
import 'jimpitan_list_notifier.dart';
import 'petugas_providers.dart';

// ─── State ───────────────────────────────────────────────────────────────────

class SesiRondaState {
  final SesiRondaModel? activeSesi;
  final List<JimpitanModel> jimpitanSesiIni;
  final bool showSummary;

  const SesiRondaState({
    this.activeSesi,
    this.jimpitanSesiIni = const [],
    this.showSummary = false,
  });

  bool get hasSesiAktif =>
      activeSesi != null && activeSesi!.status == SesiStatus.aktif;

  int get totalDiambil =>
      jimpitanSesiIni.where((j) => j.status == JimpitanStatus.diambil).length;

  int get totalKosong =>
      jimpitanSesiIni.where((j) => j.status == JimpitanStatus.kosong).length;

  Set<String> get scannedRumahIds =>
      jimpitanSesiIni.map((j) => j.rumahId).toSet();

  SesiRondaState copyWith({
    SesiRondaModel? activeSesi,
    List<JimpitanModel>? jimpitanSesiIni,
    bool? showSummary,
  }) {
    return SesiRondaState(
      activeSesi: activeSesi ?? this.activeSesi,
      jimpitanSesiIni: jimpitanSesiIni ?? this.jimpitanSesiIni,
      showSummary: showSummary ?? this.showSummary,
    );
  }
}

// ─── Notifier ────────────────────────────────────────────────────────────────

class SesiRondaNotifier extends StateNotifier<SesiRondaState> {
  final Ref _ref;

  SesiRondaNotifier(this._ref) : super(const SesiRondaState());

  /// Mulai sesi ronda baru
  void startSesi(UserModel petugas) {
    final sesi = SesiRondaModel(
      id: 'sesi_${DateTime.now().millisecondsSinceEpoch}',
      petugasId: petugas.id,
      petugasNama: petugas.nama,
      rt: petugas.rt,
      mulai: DateTime.now(),
      status: SesiStatus.aktif,
    );
    state = SesiRondaState(activeSesi: sesi);
  }

  /// Catat jimpitan setelah scan QR + ambil foto
  void recordJimpitan(RumahModel rumah, String fotoUrl) {
    if (!state.hasSesiAktif) return;

    final jimpitan = JimpitanModel(
      id: 'j_${DateTime.now().millisecondsSinceEpoch}',
      rumahId: rumah.id,
      nomorRumah: rumah.nomorRumah,
      namaKepalaKeluarga: rumah.namaKepalaKeluarga,
      sesiId: state.activeSesi!.id,
      tanggal: DateTime.now(),
      status: JimpitanStatus.diambil,
      fotoUrl: fotoUrl,
      waktuPengambilan: DateTime.now(),
      lokasi: '-7.2575° S, 112.4521° E',
      petugasId: state.activeSesi!.petugasId,
      petugasNama: state.activeSesi!.petugasNama,
    );

    _ref.read(jimpitanListNotifierProvider.notifier).addJimpitan(jimpitan);
    state = state.copyWith(
      jimpitanSesiIni: [...state.jimpitanSesiIni, jimpitan],
    );
  }

  /// Selesai ronda — otomatis tandai rumah yang belum discan sebagai "kosong"
  void endSesi() {
    if (!state.hasSesiAktif) return;

    final allRumah = _ref.read(rumahByRtProvider(state.activeSesi!.rt));
    final scanned = state.scannedRumahIds;

    final kosongList = allRumah
        .where((r) => !scanned.contains(r.id))
        .map((r) => JimpitanModel(
              id: 'j_kosong_${DateTime.now().millisecondsSinceEpoch}_${r.id}',
              rumahId: r.id,
              nomorRumah: r.nomorRumah,
              namaKepalaKeluarga: r.namaKepalaKeluarga,
              sesiId: state.activeSesi!.id,
              tanggal: DateTime.now(),
              status: JimpitanStatus.kosong,
              petugasId: state.activeSesi!.petugasId,
              petugasNama: state.activeSesi!.petugasNama,
            ))
        .toList();

    if (kosongList.isNotEmpty) {
      _ref.read(jimpitanListNotifierProvider.notifier).addAll(kosongList);
    }

    state = SesiRondaState(
      activeSesi: state.activeSesi!.copyWith(
        status: SesiStatus.selesai,
        selesai: DateTime.now(),
      ),
      jimpitanSesiIni: [...state.jimpitanSesiIni, ...kosongList],
      showSummary: true,
    );
  }

  void dismissSummary() => state = const SesiRondaState();
}

// ─── Provider ────────────────────────────────────────────────────────────────

final sesiRondaNotifierProvider =
    StateNotifierProvider<SesiRondaNotifier, SesiRondaState>(
  (ref) => SesiRondaNotifier(ref),
);
