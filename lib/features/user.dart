enum UserRole { admin, manager, user }
class User {
  String id;
  String username;
  String email;
  String passwordHash;
  UserRole role;
  String nhanVienId;
  bool isActive;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.role,
    required this.nhanVienId,
    this.isActive = true,
  });
}