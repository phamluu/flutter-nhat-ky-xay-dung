import 'package:sqflite/sqflite.dart';

import '../db_helper.dart';
import '../models/ChamCong.dart';

class ChamCongRepository {
  final _dbHelper = DBHelper.instance;

  Future<List<ChamCong>> getChamCongByDate(int idCongTrinh, String ngay) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT cc.*
      FROM cham_cong cc
      INNER JOIN nhan_vien_cong_trinh nvct 
        ON cc.id_nhan_vien_cong_trinh = nvct.id
      WHERE nvct.idCongTrinh = ? AND cc.ngay = ?
    ''', [idCongTrinh, ngay]);
    return result.map((e) => ChamCong.fromMap(e)).toList();
  }

  Future<int> insert(ChamCong cc) async {
    final db = await _dbHelper.database;
    return await db.insert('cham_cong', cc.toMap());
  }

  Future<int> update(ChamCong cc) async {
    final db = await _dbHelper.database;
    return await db.update(
      'cham_cong',
      cc.toMap(),
      where: 'id = ?',
      whereArgs: [cc.id],
    );
  }
}
