import 'package:sqflite/sqflite.dart';

import '../data/db_helper.dart';

class ThongKeService {
  final _dbHelper = DBHelper.instance;

  Future<int> getSoLuongCongTrinh() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM cong_trinh');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getSoLuongNhatKy() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM nhat_ky');
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
}