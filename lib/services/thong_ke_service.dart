import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import '../data/db_helper.dart';

class ThongKeService {
  final _dbHelper = DBHelper.instance;

  Future<int> getSoLuongCongTrinh() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM cong_trinh');
    return Sqflite.firstIntValue(result) ?? 0;
  }
  Future<int> getSoLuongCoBan() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM luong_co_ban');
    return Sqflite.firstIntValue(result) ?? 0;
  }
  Future<int> getSoLuongNhatKy([int? IdCongTrinh]) async {
    final db = await _dbHelper.database;

    // Nếu IdCongTrinh == null thì đếm tất cả, nếu có thì đếm theo id_cong_trinh
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM nhat_ky ${IdCongTrinh != null ? "WHERE id_cong_trinh = ?" : ""}',
      IdCongTrinh != null ? [IdCongTrinh] : [],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getSoLuongNhanVienCongTrinh([int? IdCongTrinh]) async {
    final db = await _dbHelper.database;

    // Nếu IdCongTrinh == null thì đếm tất cả, nếu có thì đếm theo id_cong_trinh
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM nhan_vien_cong_trinh ${IdCongTrinh != null ? "WHERE idCongTrinh = ?" : ""}',
      IdCongTrinh != null ? [IdCongTrinh] : [],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }


  Future<int> getSoLuongNhanVien() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM nhan_vien');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getSoLuongDMThuChi() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM danh_muc_thu_chi');
    return Sqflite.firstIntValue(result) ?? 0;
  }
  Future<int> getSoLuongUngLuong() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM ung_luong');
    return Sqflite.firstIntValue(result) ?? 0;
  }
  // Số lượng có mặt ngày hôm nay của 1 công trình
  Future<int> getSoLuongCoMat(int? idCongTrinh) async {
    final db = await _dbHelper.database;

    // Lấy ngày hiện tại theo định dạng yyyy-MM-dd
    final today = DateFormat("yyyy-MM-dd").format(DateTime.now());

    final result = await db.rawQuery('''
    SELECT COUNT(DISTINCT cc.id_nhan_vien_cong_trinh) as count
    FROM cham_cong cc
    JOIN nhan_vien_cong_trinh nvct ON cc.id_nhan_vien_cong_trinh = nvct.id
    WHERE nvct.idCongTrinh = ?
      AND cc.ngay = ?
      AND (cc.trang_thai_sang = 1 OR cc.trang_thai_chieu = 1)
  ''', [idCongTrinh, today]);

    return Sqflite.firstIntValue(result) ?? 0;
  }

}