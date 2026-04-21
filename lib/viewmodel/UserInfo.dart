class UserInfo {
  final String id;
  final String username;
  final String email;

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