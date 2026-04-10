import '../db_helper.dart';

class UngLuongRepository {
  Future<List<Map<String, dynamic>>> getNhanVienVaUngLuong(
      int idCongTrinh,
      int thang,
      int nam,
      ) async {
    final db = await DBHelper.instance.database;
    return await db.rawQuery('''
      SELECT 
        nvct.id as idNhanVienCongTrinh,
        nv.ho_ten,
        ul.id as idUngLuong,
        ul.soTien,
        ul.ngayUng,
        ul.lyDo
      FROM nhan_vien_cong_trinh nvct
      LEFT JOIN nhan_vien nv 
        ON nvct.idNhanVien = nv.id
      LEFT JOIN ung_luong ul 
        ON ul.idNhanVienCongTrinh = nvct.id
        AND strftime('%m', ul.ngayUng) = ?
        AND strftime('%Y', ul.ngayUng) = ?
      WHERE nvct.idCongTrinh = ?
      ORDER BY nv.ho_ten, ul.ngayUng DESC
    ''', [
      thang.toString().padLeft(2, '0'),
      nam.toString(),
      idCongTrinh,
    ]);
  }
}