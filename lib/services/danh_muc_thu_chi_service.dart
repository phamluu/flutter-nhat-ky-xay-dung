import 'package:sqflite/sqflite.dart';

import '../data/db_helper.dart';
import '../data/models/DanhMucThuChi.dart';

class DanhMucThuChiService {
  final _dbHelper = DBHelper.instance;
  Future<int> insert(DanhMucThuChi dm) async {
    final db = await _dbHelper.database;
    return await db.insert('danh_muc_thu_chi', dm.toMap());
  }

  Future<List<DanhMucThuChi>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('danh_muc_thu_chi', orderBy: 'ten ASC');
    return maps.map((e) => DanhMucThuChi.fromMap(e)).toList();
  }

  Future<int> update(DanhMucThuChi dm) async {
    final db = await _dbHelper.database;
    return await db.update(
      'danh_muc_thu_chi',
      dm.toMap(),
      where: 'id = ?',
      whereArgs: [dm.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('danh_muc_thu_chi', where: 'id = ?', whereArgs: [id]);
  }
}
