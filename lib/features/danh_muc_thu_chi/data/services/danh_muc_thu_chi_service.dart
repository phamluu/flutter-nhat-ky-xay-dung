import 'package:nhat_ky_xay_dung/data/tables/danh_muc_thu_chi_table.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../data/db_helper.dart';
import '../models/DanhMucThuChi.dart';

class DanhMucThuChiService {
  final _dbHelper = DBHelper.instance;

  Future<int> insert(DanhMucThuChi dm) async {
    final db = await _dbHelper.database;
    return await db.insert(DanhMucThuChiTable.tableName, dm.toMap());
  }

  Future<List<DanhMucThuChi>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(DanhMucThuChiTable.tableName, orderBy: '${DanhMucThuChiTable.ten} ASC');
    return maps.map((e) => DanhMucThuChi.fromMap(e)).toList();
  }

  Future<int> update(DanhMucThuChi dm) async {
    final db = await _dbHelper.database;
    return await db.update(
      DanhMucThuChiTable.tableName,
      dm.toMap(),
      where: '${DanhMucThuChiTable.id} = ?',
      whereArgs: [dm.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(DanhMucThuChiTable.tableName, where: '${DanhMucThuChiTable.id} = ?', whereArgs: [id]);
  }
}
