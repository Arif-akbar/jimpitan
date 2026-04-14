enum UserRole {
  petugas,
  warga,
  bendahara;

  String get displayName {
    switch (this) {
      case UserRole.petugas:
        return 'Petugas';
      case UserRole.warga:
        return 'Warga';
      case UserRole.bendahara:
        return 'Bendahara';
    }
  }
}
