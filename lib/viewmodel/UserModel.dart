class AuthState {
  final bool isLoggedIn;
  final String role;
  AuthState({
    required this.isLoggedIn,
    required this.role,
  });

  bool get isAdmin => role == "Admin";
  bool get isUser => role == "User";
}
class CurrentUser {
  final String email;
  final List roles;

  CurrentUser({required this.email, required this.roles});

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    return CurrentUser(
      email: json["email"],
      roles: json["roles"] ?? [],
    );
  }

  bool get isAdmin => roles.contains("Admin");
}

class UserInfo {
  final String id;
  final String username;
  String email;

  UserInfo({
    required this.id,
    required this.username,
    required this.email,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json["id"],
      username: json["userName"],
      email: json["email"],
    );
  }
}