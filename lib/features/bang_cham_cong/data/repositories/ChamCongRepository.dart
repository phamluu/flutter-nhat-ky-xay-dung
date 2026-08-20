import 'package:sqflite/sqflite.dart';

import '../../../../core/utils/trang_thai_khoa_cong.dart';
import '../../../../data/_db_helper.dart';
import '../../../../data/db_helper.dart';

// Mới
class ChamCongRepository {
  final _dbHelper = DBHelper.instance;

  Future<List<Map<String, dynamic>>> getChamCongRaw(
      int idCongTrinh, String firstDay, String lastDay) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT 
          nvct.id as id_nvct,
          nv.id as id_nv,
          nv.ho_ten,
          nvct.vaiTro,
          cc.ngay,
          cc.ghi_chu,
          cc.trang_thai_sang,
          cc.trang_thai_chieu,
          
          -- ✅ lương theo ngày áp dụng
        (
          SELECT lcb.mucLuong
          FROM luong_co_ban lcb
          WHERE lcb.idNhanVien = nv.id
            AND (lcb.ngayApDung IS NULL OR lcb.ngayApDung <= cc.ngay)
          ORDER BY lcb.ngayApDung DESC
          LIMIT 1
        ) as luongNgay
        FROM nhan_vien_cong_trinh nvct
        JOIN nhan_vien nv ON nv.id = nvct.idNhanVien
        LEFT JOIN cham_cong cc 
          ON cc.id_nhan_vien_cong_trinh = nvct.id
          AND cc.ngay BETWEEN ? AND ?
        WHERE nvct.idCongTrinh = ?
        ORDER BY nv.ho_ten
    ''', [firstDay, lastDay, idCongTrinh]);
  }
  Future<List<Map<String, dynamic>>> getUngLuongRaw(
      int idCongTrinh, String firstDay, String lastDay) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT 
          nvct.id as id_nvct,
          ul.soTien
        FROM ung_luong ul
        JOIN nhan_vien_cong_trinh nvct 
          ON nvct.id = ul.idNhanVienCongTrinh
        WHERE ul.ngayUng BETWEEN ? AND ?
          AND nvct.idCongTrinh = ?
    ''', [firstDay, lastDay, idCongTrinh]);
  }
  Future<List<Map<String, dynamic>>> getChamCongNgay(
      int idNvct, String ngay) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT 
      cc.trang_thai_sang,
      cc.trang_thai_chieu,
      cc.ghi_chu,
      -- 👉 lấy lương theo ngày
      (
        SELECT lcb.mucLuong
        FROM luong_co_ban lcb
        JOIN nhan_vien_cong_trinh nvct 
          ON nvct.idNhanVien = lcb.idNhanVien
        WHERE nvct.id = ?
          AND (lcb.ngayApDung IS NULL OR lcb.ngayApDung <= cc.ngay)
        ORDER BY lcb.ngayApDung DESC
        LIMIT 1
      ) as luongNgay

    FROM cham_cong cc
    WHERE cc.id_nhan_vien_cong_trinh = ?
      AND cc.ngay = ?
    ''', [idNvct, idNvct, ngay]);
  }
  Future<void> upsertChamCong({
    required int idNhanVienCongTrinh,
    required String ngay,
    int? trangThaiSang,
    int? trangThaiChieu,
    String? ghiChu,
  }) async
  {
    final db = await _dbHelper.database;
    // 🔍 kiểm tra đã tồn tại chưa
    final existing = await db.query(
      'cham_cong',
      where: 'id_nhan_vien_cong_trinh = ? AND ngay = ?',
      whereArgs: [idNhanVienCongTrinh, ngay],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      // 👉 UPDATE
      await db.update(
        'cham_cong',
        {
          'trang_thai_sang': trangThaiSang,
          'trang_thai_chieu': trangThaiChieu,
          'ghi_chu': ghiChu,
        },
        where: 'id_nhan_vien_cong_trinh = ? AND ngay = ?',
        whereArgs: [idNhanVienCongTrinh, ngay],
      );
    } else {
      // 👉 INSERT
      await db.insert(
        'cham_cong',
        {
          'id_nhan_vien_cong_trinh': idNhanVienCongTrinh,
          'ngay': ngay,
          'trang_thai_sang': trangThaiSang,
          'trang_thai_chieu': trangThaiChieu,
          'ghi_chu': ghiChu,
          'ngay_tao': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  //****************KHÓA CÔNG *************
  Future<void> setKhoaChamCong(String thang, bool daKhoa) async {
    final db = await _dbHelper.database;
    await db.insert(
      'khoa_cham_cong',
      {
        'thang': thang,
        'da_khoa': daKhoa
            ? TrangThaiKhoaChamCong.dakhoa.value
            : TrangThaiKhoaChamCong.chuakhoa.value,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> checkKhoaChamCong(String thang) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'khoa_cham_cong',
      where: 'thang = ?',
      whereArgs: [thang],
    );
    if (result.isEmpty) return false;
    return result.first['da_khoa'] == TrangThaiKhoaChamCong.dakhoa.value;
  }
}
