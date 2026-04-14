import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider yang akan melacak hari saat ini.
/// Gunakan provider ini jika Anda butuh meng-update UI setiap kali melewati tengah malam.
final todayProvider = StreamProvider<DateTime>((ref) {
  // Setiap menit, stream akan memancarkan DateTime saat ini.
  // Jika tanggalnya berbeda (ganti hari), provider-provider yang bergantung
  // padanya akan otomatis ter-refresh.
  return Stream.periodic(const Duration(minutes: 1), (_) => DateTime.now())
      .distinct((prev, next) => prev.year == next.year && prev.month == next.month && prev.day == next.day);
});
