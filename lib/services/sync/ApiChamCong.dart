import 'dart:convert';
import 'package:nhat_ky_xay_dung/data/tables/cham_cong_chi_tiet_table.dart';
import '../../core/services/ApiClient.dart';
import '../../features/bang_cham_cong/data/models/cham_cong_chi_tiet.dart';
class ApiChamCong {

  Future<Map<String, dynamic>> create(ChamCongChiTiet chamCong) async {
    final response = await ApiClient.post(
      ChamCongChiTietTable.tableName,
      chamCong.toMapInsert(),
    );
    final data = jsonDecode(response.body);
    return data;
  }
  Future<void> update(ChamCongChiTiet chamCong) async {
    final response = await ApiClient.put(
      "${ChamCongChiTietTable.tableName}/${chamCong.id}",
      chamCong.toMapUpdate(),
    );
    if (response.statusCode != 200) {
      throw Exception("Update thất bại: ${response.body}");
    }
  }
  Future<void> delete(int id) async {
    final response = await ApiClient.delete("${ChamCongChiTietTable.tableName}/$id");
    if (response.statusCode != 200) {
      throw Exception("Delete thất bại: ${response.body}");
    }
  }
}