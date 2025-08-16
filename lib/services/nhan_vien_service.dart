import 'package:sqflite/sqflite.dart';
import '../data/db_helper.dart';
import '../data/models/NhanVien.dart';

class NhanVienService {
  final _dbHelper = DBHelper.instance;
  Future<int> insertNhanVien(NhanVien nv) async {
    final db = await _dbHelper.database;
    return await db.insert('nhan_vien', nv.toMap());
  }

  Future<List<NhanVien>> getAllNhanVien() async {
    final db = await _dbHelper.database;

    final maps = await db.query('nhan_vien', orderBy: 'ho_ten ASC');
    return maps.map((e) => NhanVien.fromMap(e)).toList();
  }

  Future<int> updateNhanVien(NhanVien nv) async {
    final db = await _dbHelper.database;
    return await db.update(
      'nhan_vien',
      nv.toMap(),
      where: 'id = ?',
      whereArgs: [nv.id],
    );
  }

  Future<int> deleteNhanVien(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'nhan_vien',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
