import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = "https://xaydung.inanhonglen.com/api";

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  /// POST
  static Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return await http.post(
      Uri.parse("$baseUrl/$path"),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  /// PUT (update)
  static Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return await http.put(
      Uri.parse("$baseUrl/$path"),
      headers: headers,
      body: jsonEncode(body),
    );
  }
  /// DELETE
  static Future<http.Response> delete(String path) async {
    final headers = await _getHeaders();
    return await http.delete(
      Uri.parse("$baseUrl/$path"),
      headers: headers,
    );
  }
  /// GET
  static Future<http.Response> get(String path) async {
    final headers = await _getHeaders();

    return await http.get(
      Uri.parse("$baseUrl/$path"),
      headers: headers,
    );
  }
}