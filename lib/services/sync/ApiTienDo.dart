import 'dart:convert';

import 'package:nhat_ky_xay_dung/data/models/TienDoCongTrinhModel.dart';

import '../../core/services/ApiClient.dart';
import '../../data/models/CongTrinh.dart';

class ApiTienDo {

  Future<Map<String, dynamic>> create(TienDoCongTrinhModel tienDo) async {
    final response = await ApiClient.post(
      "tiendo",
      tienDo.toMap(),
    );
    final data = jsonDecode(response.body);
    return data;
  }
  Future<void> update(TienDoCongTrinhModel tienDo) async {
    final response = await ApiClient.put(
      "tiendo/${tienDo.id}",
      tienDo.toMap(),
    );
    if (response.statusCode != 200) {
      throw Exception("Update thất bại: ${response.body}");
    }
  }
  Future<void> delete(int id) async {
    final response = await ApiClient.delete("tiendo/$id");
    if (response.statusCode != 200) {
      throw Exception("Delete thất bại: ${response.body}");
    }
  }
}