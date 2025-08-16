import 'package:sqflite/sqflite.dart';
import '../data/db_helper.dart';
import '../data/models/NhatKy.dart';

class NhatKyService {
  final _dbHelper = DBHelper.instance;
  Future<int> insertNhatKy(NhatKy nk) async {
    final db = await _dbHelper.database;
    return await db.insert('nhat_ky', nk.toMap());
  }

  Future<List<NhatKy>> getAllNhatKy() async {
    final db = await _dbHelper.database;
    final maps = await db.query('nhat_ky', orderBy: 'ngay_tao DESC');
    return maps.map((e) => NhatKy.fromMap(e)).toList();
  }

  Future<int> updateNhatKy(NhatKy nk) async {
    final db = await _dbHelper.database;
    return await db.update(
      'nhat_ky',
      nk.toMap(),
      where: 'id = ?',
      whereArgs: [nk.id],
    );
  }

  Future<int> deleteNhatKy(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'nhat_ky',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
