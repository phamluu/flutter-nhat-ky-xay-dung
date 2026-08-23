import 'dart:convert';

import '../../core/services/ApiClient.dart';
import '../../features/cong_trinh/data/models/CongTrinh.dart';
import '../../features/cong_trinh/data/models/NhanVienCongTrinh.dart';

class ApiNhanVienCongTrinh {

  Future<Map<String, dynamic>> create(NhanVienCongTrinh nvct) async {
    final response = await ApiClient.post(
      "nhanviencongtrinh",
      nvct.toMap(),
    );
    final data = jsonDecode(response.body);
    return data;
  }
  Future<void> update(NhanVienCongTrinh nvct) async {
    final response = await ApiClient.put(
      "nhanviencongtrinh/${nvct.id}",
      nvct.toMap(),
    );
    if (response.statusCode != 200) {
      throw Exception("Update thất bại: ${response.body}");
    }
  }
  Future<void> delete(int id) async {
    final response = await ApiClient.delete("nhanviencongtrinh/$id");
    if (response.statusCode != 200) {
      throw Exception("Delete thất bại: ${response.body}");
    }
  }
}