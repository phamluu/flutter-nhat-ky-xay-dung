import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_table.dart';
import 'package:nhat_ky_xay_dung/features/cong_trinh/data/models/NhanVienCongTrinh.dart';

import '../../../../data/db_helper.dart';

class NhanVienCongTrinhRepo {
  final _dbHelper = DBHelper.instance;
  Future<List<NhanVienCongTrinh>> getDanhSachNhanVien(int idCongTrinh) async {
    final db = await _dbHelper.database;
    final String sql = '''
    SELECT 
      nvct.*,
      nv.${NhanVienTable.hoTen},
      nv.${NhanVienTable.soDienThoai}
    FROM ${NhanVienCongTrinhTable.tableName} nvct
    LEFT JOIN ${NhanVienTable.tableName} nv ON nvct.${NhanVienCongTrinhTable.idNhanVien} = nv.${NhanVienTable.id}
    WHERE nvct.${NhanVienCongTrinhTable.idCongTrinh} = ? 
      AND nvct.${NhanVienCongTrinhTable.isDeleted} = 0
    ORDER BY datetime(nvct.${NhanVienCongTrinhTable.id}) DESC
  ''';
    final maps = await db.rawQuery(sql, [idCongTrinh]);
    return maps.map((map) => NhanVienCongTrinh.fromMap(map)).toList();
  }
}