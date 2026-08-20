import 'package:nhat_ky_xay_dung/data/tables/luong_co_ban_table.dart';
import 'package:sqflite/sqflite.dart';

import '../../../nhan_vien/data/services/nhan_vien_service.dart';
import '../models/LuongCoBan.dart';
import '../../../../data/db_helper.dart';

class LuongCoBanRepository {
  final DBHelper _dbHelper = DBHelper.instance;

  Future<int> insert(Luongcoban luong) async {
    final db = await _dbHelper.database;
    return await db.insert(LuongCoBanTable.tableName, luong.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(Luongcoban luong) async {
    final db = await _dbHelper.database;
    return await db.update(
      LuongCoBanTable.tableName,
      luong.toMap(),
      where: '${LuongCoBanTable.id} = ?',
      whereArgs: [luong.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(LuongCoBanTable.tableName, where: '${LuongCoBanTable.id} = ?', whereArgs: [id]);
  }

  Future<Luongcoban?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(LuongCoBanTable.tableName, where: '${LuongCoBanTable.id} = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Luongcoban.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Luongcoban>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(LuongCoBanTable.tableName, orderBy: "${LuongCoBanTable.ngayApDung} DESC");
    final nhanViens = await NhanVienService().getAllNhanVien();
    return List.generate(maps.length, (i) {
      return Luongcoban.fromMap(maps[i], nhanViens: nhanViens);
    });
  }


  Future<List<Luongcoban>> getByNhanVien(int idNhanVien) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      LuongCoBanTable.tableName,
      where: '${LuongCoBanTable.idNhanVien} = ?',
      whereArgs: [idNhanVien],
      orderBy: '${LuongCoBanTable.ngayApDung} DESC',
    );

    return List.generate(maps.length, (i) {
      return Luongcoban.fromMap(maps[i]);
    });
  }
}
