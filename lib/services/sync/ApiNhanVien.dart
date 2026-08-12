import 'dart:convert';

import 'package:nhat_ky_xay_dung/features/nhan_vien/data/models/NhanVien.dart';

import '../../core/services/ApiClient.dart';
import '../../features/cong_trinh/data/models/CongTrinh.dart';

class ApiNhanVien {
  Future<Map<String, dynamic>> createNhanVien(NhanVien nhanVien) async {
    final response = await ApiClient.post(
      "nhanvien",
      nhanVien.toApi(),
    );
    print("🟡 CREATE STATUS: ${response.statusCode}");
    print("🟡 CREATE BODY: '${response.body}'");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Create thất bại: ${response.body}");
    }

    if (response.body.isEmpty) {
      throw Exception("Response rỗng từ server");
    }

    return jsonDecode(response.body);
  }

  Future<void> updateNhanVien(NhanVien nhanVien) async {
    final response = await ApiClient.put(
      "nhanvien/${nhanVien.server_id}",
      nhanVien.toApi(),
    );

    if (response.statusCode != 200) {
      throw Exception("Update thất bại: ${response.body}");
    }

    if (response.body.isNotEmpty) {
      try {
        jsonDecode(response.body);
      } catch (e) {
        print("⚠️ Response không phải JSON: ${response.body}");
      }
    }
  }
  Future<Map<String, dynamic>> deleteNhanVieh(String id) async {
    final response = await ApiClient.delete("nhanvien/$id");
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data["message"] ?? "Delete thất bại");
    }
    return data;
  }
}