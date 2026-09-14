import 'package:nhat_ky_xay_dung/data/tables/cham_cong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhat_ky_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/thu_chi_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/tien_do_cong_trinh_table.dart';

import '../../../../core/enum/feature_enum.dart';
import '../../../../core/services/PermissionManager.dart';
import '../../../../core/services/trial_service.dart';
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
    await PermissionManager.instance.assertPermission(FeatureEnum.saveCongTrinh);
    final db = await _dbHelper.database;
    try{
      return await db.insert(CongTrinhTable.tableName, congTrinh.toMapInsert());
    }catch(e){
      throw Exception('Lỗi: $e');
    }

  }
  Future<void> updateCongTrinh(CongTrinh ct) async {
    await PermissionManager.instance.assertPermission(FeatureEnum.saveCongTrinh);
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
    await PermissionManager.instance.assertPermission(FeatureEnum.deleteCongTrinh);
    final db = await _dbHelper.database;
    try{
      // Kiểm tra các ràng buộc với thu chi, nhân viên công trình, kỳ lương, kế hoạch, nhật ký,
          final results = await Future.wait([
              db.query(ThuChiTable.tableName,
                  columns: [ThuChiTable.id_cong_trinh],
                  where: '${ThuChiTable.id_cong_trinh} = ?',
                  whereArgs: [id],
                  limit: 1
                  ),
              db.query(NhanVienCongTrinhTable.tableName,
                  columns: [NhanVienCongTrinhTable.idCongTrinh],
                  where: '${NhanVienCongTrinhTable.idCongTrinh} = ?',
                  whereArgs: [id],
                  limit: 1
              ),
              db.query(ChamCongTable.tableName,
                  columns: [ChamCongTable.idCongTrinh],
                  where: '${ChamCongTable.idCongTrinh} = ?',
                  whereArgs: [id],
                  limit: 1
                  ),
              db.query(TienDoCongTrinhTable.tableName,
                  columns: [TienDoCongTrinhTable.idCongTrinh],
                  where: '${TienDoCongTrinhTable.idCongTrinh} = ?',
                  whereArgs: [id],
                  limit: 1
                  ),
              db.query(NhatKyTable.tableName,
                  columns: [NhatKyTable.idCongTrinh],
                  where: '${NhatKyTable.idCongTrinh} = ?',
                  whereArgs: [id],
                  limit: 1
                  )
            ]);

            if(results[0].isNotEmpty){
              throw Exception('Công trình có dữ liệu thu chi. Hãy xóa dữ liệu thu chi trước');
            }
            if(results[1].isNotEmpty){
              throw Exception('Công trình có dữ liệu nhân viên công trình. Hãy xóa dữ liệu nhân viên công trình trước');
            }
            if(results[2].isNotEmpty){
              throw Exception('Công trình có dữ liệu bảng chấm công. Hãy xóa dữ liệu bảng chấm công trước');
            }
            if(results[3].isNotEmpty){
              throw Exception('Công trình có dữ liệu kế hoạch công việc. Hãy xóa dữ liệu kế hoạch công việc trước');
            }
            if(results[4].isNotEmpty){
              throw Exception('Công trình có dữ liệu nhật ký công trin. Hãy xóa dữ liệu nhật ký công trình trước');
            }
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
    await PermissionManager.instance.assertPermission(FeatureEnum.saveCongTrinh);
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