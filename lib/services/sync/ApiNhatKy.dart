import 'dart:convert';

import '../../core/services/ApiClient.dart';
import '../../features/cong_trinh/data/models/CongTrinh.dart';
import '../../features/nhat_ky_cong_trinh/data/models/NhatKy.dart';

class ApiNhatKy {

  Future<Map<String, dynamic>> create(NhatKy nhatKy) async {
    final response = await ApiClient.post(
      "nhatky",
      nhatKy.toMap(),
    );
    final data = jsonDecode(response.body);
    return data;
  }
  Future<void> update(NhatKy nhatKy) async {
    final response = await ApiClient.put(
      "nhatky/${nhatKy.id}",
      nhatKy.toMap(),
    );
    if (response.statusCode != 200) {
      throw Exception("Update thất bại: ${response.body}");
    }
  }
  Future<void> delete(int id) async {
    final response = await ApiClient.delete("nhatky/$id");
    if (response.statusCode != 200) {
      throw Exception("Delete thất bại: ${response.body}");
    }
  }
}