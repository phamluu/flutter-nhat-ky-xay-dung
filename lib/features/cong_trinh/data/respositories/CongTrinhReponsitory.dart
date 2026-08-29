import 'package:nhat_ky_xay_dung/data/tables/cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/tien_do_cong_trinh_table.dart';

import '../models/CongTrinh.dart';
import '../../../../data/db_helper.dart';

class CongtrinhReponsitory {
  final _dbHelper = DBHelper.instance;

  Future<List<CongTrinh>> getDanhSachCongTrinh() async {
    final db = await _dbHelper.database;
    final maps = await db.query(CongTrinhTable.tableName, orderBy: 'datetime(${CongTrinhTable.ngayTao}) DESC',);
    return maps.map((map) => CongTrinh.fromMap(map)).toList();
  }

  Future<CongTrinh?> getCongTrinh(idCongTrinh) async{
    final db = await _dbHelper.database;
    final maps = await db.query(CongTrinhTable.tableName,where: '${CongTrinhTable.id} = ?',
        whereArgs: [idCongTrinh], orderBy: '${CongTrinhTable.ngayTao} DESC');
    if (maps.isNotEmpty) {
      return CongTrinh.fromMap(maps.first);
    } else {
      return null;
    }
  }


  Future<int> themCongTrinh(CongTrinh congTrinh) async {
    final db = await _dbHelper.database;
    try{
      return await db.insert(CongTrinhTable.tableName, congTrinh.toMapInsert());
    }catch(e){
      throw Exception('Lỗi: $e');
    }

  }
  Future<void> updateCongTrinh(CongTrinh ct) async {
    final db = await _dbHelper.database;
    try{
      await db.update(
        CongTrinhTable.tableName,
        ct.toMapUpdate(),
        where: '${CongTrinhTable.id} = ?',
        whereArgs: [ct.id],
      );
    }catch(e){
      throw Exception('Lỗi: $e');
    }

  }
  Future<int> deleteCongTrinh(int id) async {
    final db = await _dbHelper.database;
    try{
      return await db.delete(
        CongTrinhTable.tableName,
        where: '${CongTrinhTable.id} = ?',
        whereArgs: [id],
      );
    }catch(e){
      throw Exception('Lỗi: $e');
    }
  }

  Future<List<CongTrinh>> getCongTrinhWithTienDo() async {
    final db = await DBHelper.instance.database;
    final maps = await db.rawQuery('''
    SELECT 
      ct.*,
      (
        SELECT 
          CASE 
            WHEN SUM(${TienDoCongTrinhTable.trongSo}) = 0 THEN 0
            ELSE SUM(${TienDoCongTrinhTable.phanTramThucTe} * ${TienDoCongTrinhTable.trongSo}) / SUM(${TienDoCongTrinhTable.trongSo})
          END
        FROM ${TienDoCongTrinhTable.tableName} td
        WHERE td.${TienDoCongTrinhTable.idCongTrinh} = ct.${CongTrinhTable.id}
      ) as tienDo
    FROM ${CongTrinhTable.tableName} ct
  ''');
    return maps.map((map) => CongTrinh.fromMap(map)).toList();
  }
}