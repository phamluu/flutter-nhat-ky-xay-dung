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

  Future<List<Map<String, dynamic>>> getUngLuong({
    required int idCongTrinh,
    DateTime? tuNgay,
    DateTime? denNgay,
  }) async {
    final db = await DBHelper.instance.database;

    String dateCondition = '';
    final args = <dynamic>[];

    if (tuNgay != null) {
      dateCondition += ' AND date(ul.ngayUng) >= date(?)';
      args.add(_formatDate(tuNgay));
    }

    if (denNgay != null) {
      dateCondition += ' AND date(ul.ngayUng) <= date(?)';
      args.add(_formatDate(denNgay));
    }

    args.add(idCongTrinh);

    return await db.rawQuery('''
    SELECT
      nvct.id AS idNhanVienCongTrinh,
      ul.id AS idUngLuong,
      ul.soTien
    FROM nhan_vien_cong_trinh nvct
    LEFT JOIN ung_luong ul
      ON ul.idNhanVienCongTrinh = nvct.id
      AND ul.is_deleted = 0
      $dateCondition
    WHERE nvct.idCongTrinh = ?
    ORDER BY date(ul.ngayUng) DESC
  ''', args);
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
