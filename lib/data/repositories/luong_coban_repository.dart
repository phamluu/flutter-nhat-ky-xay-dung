import 'package:sqflite/sqflite.dart';

import '../../services/nhan_vien_service.dart';
import '../db_helper.dart';
import '../models/LuongCoBan.dart';

class LuongCoBanRepository {
  final DBHelper _dbHelper = DBHelper.instance;

  Future<int> insert(Luongcoban luong) async {
    final db = await _dbHelper.database;
    return await db.insert('luong_co_ban', luong.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(Luongcoban luong) async {
    final db = await _dbHelper.database;
    return await db.update(
      'luong_co_ban',
      luong.toMap(),
      where: 'id = ?',
      whereArgs: [luong.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('luong_co_ban', where: 'id = ?', whereArgs: [id]);
  }

  Future<Luongcoban?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('luong_co_ban', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Luongcoban.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Luongcoban>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('luong_co_ban', orderBy: "ngayApDung DESC");
    final nhanViens = await NhanVienService().getAllNhanVien();
    return List.generate(maps.length, (i) {
      return Luongcoban.fromMap(maps[i], nhanViens: nhanViens);
    });
  }


  Future<List<Luongcoban>> getByNhanVien(int idNhanVien) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'luong_co_ban',
      where: 'idNhanVien = ?',
      whereArgs: [idNhanVien],
      orderBy: 'ngayApDung DESC',
    );

    return List.generate(maps.length, (i) {
      return Luongcoban.fromMap(maps[i]);
    });
  }
}
