import 'package:jimpitan_digital/shared/enums/user_role.dart';

class UserModel {
  final String id;
  final String nama;
  final String email;
  final UserRole role;
  final String rt;
  final String? rumahId; // hanya untuk warga

  const UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    required this.rt,
    this.rumahId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserModel(id: $id, nama: $nama, role: $role, rt: $rt)';
}
