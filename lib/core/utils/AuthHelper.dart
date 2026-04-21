import 'package:shared_preferences/shared_preferences.dart';

import '../services/ApiClient.dart';

class AuthHelper {
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    if (token == null || token.isEmpty) return false;
    try {
      final res = await ApiClient.get("user/me");
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", token);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("access_token");
  }
}