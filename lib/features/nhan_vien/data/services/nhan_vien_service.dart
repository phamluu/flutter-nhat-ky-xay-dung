import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_table.dart';

import '../../../../data/db_helper.dart';
import '../models/NhanVien.dart';

class NhanVienService {
  final _dbHelper = DBHelper.instance;

  Future<int> insertNhanVien(NhanVien nv) async {
    final db = await _dbHelper.database;
    try{
      return await db.insert(NhanVienTable.tableName, nv.toMap());
    }catch(e){
      throw Exception('Lỗi: $e');
    }
  }

  Future<NhanVien?> getNhanVienById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      NhanVienTable.tableName,
      where: '${NhanVienTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return NhanVien.fromMap(maps.first);
    }
    return null;
  }

  Future<List<NhanVien>> getAllNhanVien() async {
    final db = await _dbHelper.database;

    final maps = await db.query(NhanVienTable.tableName, orderBy: '${NhanVienTable.hoTen} ASC');
    return maps.map((e) => NhanVien.fromMap(e)).toList();
  }

  Future<int> updateNhanVien(NhanVien nv) async {
    final db = await _dbHelper.database;
    try{
      return await db.update(
        NhanVienTable.tableName,
        nv.toMap(),
        where: '${NhanVienTable.id} = ?',
        whereArgs: [nv.id],
      );
    }catch(e){
      throw Exception("Lỗi: $e");
    }
  }

  Future<int> deleteNhanVien(int id) async {
    final db = await _dbHelper.database;
    try{
      return await db.delete(
        NhanVienTable.tableName,
        where: '${NhanVienTable.id} = ?',
        whereArgs: [id],
      );
    }catch(e){
        throw Exception('Không thể xóa. Nhân viên này đã có dữ liệu trên hệ thống ');
    }
  }
}
