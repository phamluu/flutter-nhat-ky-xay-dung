import 'dart:convert';

import '../../core/services/ApiClient.dart';
import '../../data/models/CongTrinh.dart';

class ApiCongTrinh {

  Future<Map<String, dynamic>> createCongTrinh(CongTrinh congTrinh) async {
    final response = await ApiClient.post(
      "congtrinh",
      congTrinh.toMapInsert(),
    );
    final data = jsonDecode(response.body);
    return data;
  }
  Future<void> updateCongTrinh(CongTrinh congTrinh) async {
    final response = await ApiClient.put(
      "congtrinh/${congTrinh.server_id}", // ✅ đúng URL
      congTrinh.toMapUpdate(),     // ✅ đúng body
    );
    if (response.statusCode != 200) {
      throw Exception("Update thất bại: ${response.body}");
    }
  }
  Future<void> deleteCongTrinh(int id) async {
    final response = await ApiClient.delete("congtrinh/$id");
    if (response.statusCode != 200) {
      throw Exception("Delete thất bại: ${response.body}");
    }
  }
}