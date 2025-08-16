import 'package:sqflite/sqflite.dart';

import '../data/db_helper.dart';
import '../data/models/NhanVienCongTrinh.dart';

class NhanVienCongTrinhService {
  final _dbHelper = DBHelper.instance;

  Future<int> insert(NhanVienCongTrinh item) async {
    final db = await _dbHelper.database;
    return await db.insert('nhan_vien_cong_trinh', item.toMap());
  }

  Future<int> update(NhanVienCongTrinh item) async {
    final db = await _dbHelper.database;
    return await db.update(
      'nhan_vien_cong_trinh',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'nhan_vien_cong_trinh',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<NhanVienCongTrinh?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'nhan_vien_cong_trinh',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return NhanVienCongTrinh.fromMap(maps.first);
    return null;
  }

  Future<List<NhanVienCongTrinh>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('nhan_vien_cong_trinh', orderBy: 'id DESC');
    return maps.map((e) => NhanVienCongTrinh.fromMap(e)).toList();
  }

  Future<List<NhanVienCongTrinh>> getByNhanVien(int idNhanVien) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'nhan_vien_cong_trinh',
      where: 'idNhanVien = ?',
      whereArgs: [idNhanVien],
    );
    return maps.map((e) => NhanVienCongTrinh.fromMap(e)).toList();
  }

  Future<List<NhanVienCongTrinh>> getByCongTrinh(int idCongTrinh) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'nhan_vien_cong_trinh',
      where: 'idCongTrinh = ?',
      whereArgs: [idCongTrinh],
    );
    return maps.map((e) => NhanVienCongTrinh.fromMap(e)).toList();
  }
}
