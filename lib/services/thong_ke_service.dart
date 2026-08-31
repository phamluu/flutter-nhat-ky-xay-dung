import 'package:nhat_ky_xay_dung/data/tables/danh_muc_thu_chi_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhat_ky_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/thu_chi_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/tien_do_cong_trinh_table.dart';
import 'package:sqflite/sqflite.dart';
import '../data/db_helper.dart';
import '../data/tables/cham_cong_table.dart';

class ThongKeService {
  final _dbHelper = DBHelper.instance;
  Future<int> getSoLuongBangChamCong([int? IdCongTrinh]) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${ChamCongTable.tableName} ${IdCongTrinh != null ? "WHERE ${ChamCongTable.idCongTrinh} = ?" : ""}',
      IdCongTrinh != null ? [IdCongTrinh] : [],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
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
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${NhatKyTable.tableName} ${IdCongTrinh != null ? "WHERE ${NhatKyTable.idCongTrinh} = ?" : ""}',
      IdCongTrinh != null ? [IdCongTrinh] : [],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }
  Future<int> getSoLuongKeHoach([int? IdCongTrinh]) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${TienDoCongTrinhTable.tableName} ${IdCongTrinh != null ? "WHERE ${TienDoCongTrinhTable.idCongTrinh} = ?" : ""}',
      IdCongTrinh != null ? [IdCongTrinh] : [],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
  Future<int> getSoLuongNhanVienCongTrinh([int? IdCongTrinh]) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${NhanVienCongTrinhTable.tableName} ${IdCongTrinh != null ? "WHERE ${NhanVienCongTrinhTable.idCongTrinh} = ?" : ""}',
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
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM ${DanhMucThuChiTable.tableName}');
    return Sqflite.firstIntValue(result) ?? 0;
  }
  Future<int> getSoLuongUngLuong([int? idCongTrinh]) async {
    final db = await _dbHelper.database;

    final sql = '''
    SELECT COUNT(ul.id) AS count
    FROM ung_luong ul
    LEFT JOIN ${NhanVienCongTrinhTable.tableName} nvct ON nvct.id = ul.idNhanVienCongTrinh
    ${idCongTrinh != null ? 'WHERE nvct.idCongTrinh = ?' : ''}
  ''';

    final args = idCongTrinh != null ? [idCongTrinh] : [];
    final r = await db.rawQuery(sql, args);
    return Sqflite.firstIntValue(r) ?? 0;
  }

  Future<int> getSoLanThuChi([int? IdCongTrinh]) async {
    final db = await _dbHelper.database;

    // Nếu IdCongTrinh == null thì đếm tất cả, nếu có thì đếm theo id_cong_trinh
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${ThuChiTable.tableName} ${IdCongTrinh != null ? "WHERE id_cong_trinh = ?" : ""}',
      IdCongTrinh != null ? [IdCongTrinh] : [],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

}