import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimpitan_digital/shared/enums/user_role.dart';
import 'package:jimpitan_digital/shared/models/user_model.dart';
import 'package:jimpitan_digital/core/data/dummy_data.dart';

// ─── State ───────────────────────────────────────────────────────────────────

class AuthState {
  final UserModel? currentUser;
  final bool isLoading;

  const AuthState({this.currentUser, this.isLoading = false});

  bool get isLoggedIn => currentUser != null;

  AuthState copyWith({UserModel? currentUser, bool? isLoading}) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ─── Notifier ────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Login dengan email dan password dari input user
  Future<UserModel> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    
    // Simulasi delay jaringan (Bisa dihapus saat menggunakan Firebase)
    await Future.delayed(const Duration(milliseconds: 500));

    // Validasi credential (dummy logic)
    if (password != '123456') {
      state = state.copyWith(isLoading: false);
      throw Exception('Peringatan Akun Salah');
    }

    try {
      // Pengecekan email terhadap dummy data
      final user = DummyData.users.firstWhere((u) => u.email == email);
      state = AuthState(currentUser: user, isLoading: false);
      return user;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      throw Exception('Peringatan Akun Salah');
    }
  }

  /// Login dengan role tertentu (dummy — pilih user pertama dengan role tsb)
  void loginAs(UserRole role) {
    state = state.copyWith(isLoading: true);
    final user = DummyData.users.firstWhere((u) => u.role == role);
    state = AuthState(currentUser: user);
  }

  /// Login sebagai warga tertentu (untuk demo multi-warga)
  void loginAsWargaWithRumah(String rumahId) {
    state = state.copyWith(isLoading: true);
    final user = DummyData.users.firstWhere(
      (u) => u.role == UserRole.warga && u.rumahId == rumahId,
      orElse: () => DummyData.getUserByRole(UserRole.warga),
    );
    state = AuthState(currentUser: user);
  }

  void logout() => state = const AuthState();
}

// ─── Provider ────────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

/// Shorthand untuk current user
final currentUserProvider = Provider<UserModel?>(
  (ref) => ref.watch(authProvider).currentUser,
);
