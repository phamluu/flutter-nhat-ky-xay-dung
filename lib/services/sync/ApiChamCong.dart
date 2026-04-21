import 'dart:convert';
import 'package:nhat_ky_xay_dung/data/models/ChamCong.dart';
import '../../core/services/ApiClient.dart';
class ApiChamCong {

  Future<Map<String, dynamic>> create(ChamCong chamCong) async {
    final response = await ApiClient.post(
      "chamcong",
      chamCong.toMap(),
    );
    final data = jsonDecode(response.body);
    return data;
  }
  Future<void> update(ChamCong chamCong) async {
    final response = await ApiClient.put(
      "chamcong/${chamCong.id}",
      chamCong.toMap(),
    );
    if (response.statusCode != 200) {
      throw Exception("Update thất bại: ${response.body}");
    }
  }
  Future<void> delete(int id) async {
    final response = await ApiClient.delete("chamcong/$id");
    if (response.statusCode != 200) {
      throw Exception("Delete thất bại: ${response.body}");
    }
  }
}