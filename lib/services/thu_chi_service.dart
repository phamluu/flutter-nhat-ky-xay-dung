import 'package:sqflite/sqflite.dart';

import '../data/db_helper.dart';
import '../data/models/ThuChi.dart';

class ThuChiService {
  final _dbHelper = DBHelper.instance;
  Future<int> insert(ThuChi tc) async {
    final db = await _dbHelper.database;
    return await db.insert('thu_chi', tc.toMap());
  }

  Future<List<ThuChi>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('thu_chi', orderBy: 'ngay DESC');
    return maps.map((e) => ThuChi.fromMap(e)).toList();
  }

  Future<int> update(ThuChi tc) async {
    final db = await _dbHelper.database;
    return await db.update(
      'thu_chi',
      tc.toMap(),
      where: 'id = ?',
      whereArgs: [tc.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('thu_chi', where: 'id = ?', whereArgs: [id]);
  }
  Future<int> countByDanhMuc(int idDanhMuc) async {
    final db = await _dbHelper.database;
    final res = await db.rawQuery(
      'SELECT COUNT(*) as c FROM thu_chi WHERE id_danh_muc_thu_chi = ?',
      [idDanhMuc],
    );
    return (res.first['c'] as int?) ?? 0;
  }

}
