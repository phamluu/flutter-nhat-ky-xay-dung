import 'package:nhat_ky_xay_dung/core/utils/trang_thai_luong.dart';
import 'package:nhat_ky_xay_dung/data/tables/cham_cong_chi_tiet_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/ky_luong_chi_tiet_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/ky_luong_table.dart';

import '../../../../core/utils/trang_thai_khoa_cong.dart';
import '../../../../data/db_helper.dart';
import '../../../../data/tables/cham_cong_table.dart';
import '../models/bang_cham_cong.dart';

class BangChamCongRepository {
  final _dbHelper = DBHelper.instance;

  Future<List<BangChamCong>> getByCongTrinh(int? idCongTrinh) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      ChamCongTable.tableName,
      where: '${ChamCongTable.idCongTrinh} = ?',
      whereArgs: [idCongTrinh],
      orderBy: '${ChamCongTable.thang} DESC',
    );
    return maps.map((map) => BangChamCong.fromMap(map)).toList();
  }
  Future<BangChamCong?> getBangChamCong({int? idBangChamCong}) async {
    if (idBangChamCong == null) return null;
    final db = await _dbHelper.database;
    final maps = await db.query(
      ChamCongTable.tableName,
      where: '${ChamCongTable.id} = ?',
      whereArgs: [idBangChamCong],
      limit: 1,
    );
    return maps.isNotEmpty ? BangChamCong.fromMap(maps.first) : null;
  }
  Future<int> insert(BangChamCong bangChamCong) async {
    final db = await _dbHelper.database;
    return await db.insert(ChamCongTable.tableName, bangChamCong.toMapInsert());
  }
  // Tự động xóa chi tiết vì đã ràng buộc
  Future<int> delete({int? idBangChamCong,int? idCongTrinh,int? thang,int? nam,}) async {
    final db = await _dbHelper.database;
    // Kiểm tra tồn tại chi tiết chấm công
    // Kiểm tra tồn tại kỳ lương
    // Kiểm tra trạng thái chấm công
    final results = await Future.wait([
      db.query(ChamCongChiTietTable.tableName,
          columns: [ChamCongChiTietTable.id],
          where: '${ChamCongChiTietTable.idChamCong} = ?',
        whereArgs: [idBangChamCong],
        limit: 1
      ),
      db.query(KyLuongTable.tableName,columns: [KyLuongChiTietTable.id],
        where: '${KyLuongTable.idBangChamCong} = ?',
        whereArgs: [idBangChamCong]),
      db.query(ChamCongTable.tableName, columns: [ChamCongTable.id],
      where: '${ChamCongTable.id} = ? AND ${ChamCongTable.daKhoa} = ${TrangThaiKhoaChamCong.dakhoa.value}',
      whereArgs: [idBangChamCong],
      limit: 1)
    ]);
    if(results[0].isNotEmpty){
      throw Exception('Bảng chấm công đang tồn tại dữ liệu chấm công ngày. Hãy xóa dữ liệu của bảng chấm công');
    }
    if(results[1].isNotEmpty){
      throw Exception('Bảng chấm công đang tồn tại dữ liệu lương. Hãy xóa dữ liệu của bảng chấm công');
    }
    if(results[2].isNotEmpty){
      throw Exception('Bảng chấm công đang khóa. Hãy mở khóa chấm công');
    }
    try{
      if (idBangChamCong != null) {
        return db.delete(
          ChamCongTable.tableName,
          where: '${ChamCongTable.id} = ?',
          whereArgs: [idBangChamCong],
        );
      }
      if (idCongTrinh == null || thang == null || nam == null) {
        throw ArgumentError(
          'idCongTrinh, thang, nam là bắt buộc khi không có idBangChamCong',
        );
      }
      final thangKey = '$nam-${thang.toString().padLeft(2, '0')}';
      return db.delete(
        ChamCongTable.tableName,
        where:
        '${ChamCongTable.idCongTrinh} = ? AND ${ChamCongTable.thang} = ?',
        whereArgs: [idCongTrinh, thangKey],
      );
    }catch(e){
      throw Exception('Tồn tại dữ liệu chấm công');
    }
  }
  // Lấy id bảng chấm công
  Future<int?> getChamCongId({int? idCongTrinh, int? thang, int? nam}) async
    {
      final db = await _dbHelper.database;
      final thangValue = '$nam-${thang.toString().padLeft(2, '0')}';

      final result = await db.query(
        ChamCongTable.tableName,
        columns: [ChamCongTable.id],
        where: '''
        ${ChamCongTable.idCongTrinh} = ?
        AND ${ChamCongTable.thang} = ?
        AND ${ChamCongTable.isDeleted} = 0
      ''',
        whereArgs: [
          idCongTrinh,
          thangValue,
        ],
        limit: 1,
      );

      if (result.isEmpty) {
        return null;
      }

      return result.first[ChamCongTable.id] as int;
    }

  Future<void> setKhoaChamCong( {int? idBangChamCong, required bool daKhoa} ) async
    {
          final db = await _dbHelper.database;
          final trangThai = daKhoa ? TrangThaiKhoaChamCong.dakhoa.value: TrangThaiKhoaChamCong.chuakhoa.value;
          // Kiểm tra nếu là mở khóa chấm công cần kiểm tra tồn tại trạng thái chốt lương
          if(trangThai == TrangThaiKhoaChamCong.chuakhoa.value){
            final hasChotLuong = await db.query(KyLuongTable.tableName,
                columns: [KyLuongTable.id],
                where: '${KyLuongTable.idBangChamCong} = ? AND ${KyLuongTable.trangThai} = ${TrangThaiLuong.dachot.value}',
                whereArgs: [idBangChamCong],
                limit: 1
            );
            if(hasChotLuong.isNotEmpty){
              throw Exception('Không thể mở khóa chấm công. Bảng chấm công đã tồn tại dữ liệu chốt lương');
            }
          }
          final data = {
            ChamCongTable.daKhoa: trangThai,
            ChamCongTable.updatedAt: DateTime.now().toIso8601String(),
            ChamCongTable.isSynced: 0,
          };
          if (idBangChamCong != null) {
            await db.update(
              ChamCongTable.tableName,
              data,
              where: '${ChamCongTable.id} = ?',
              whereArgs: [idBangChamCong],
            );
            return;
          }
    }
  Future<bool> checkKhoaChamCong({int? idBangChamCong}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      ChamCongTable.tableName,
      columns: [
        ChamCongTable.daKhoa,
      ],
      where: '${ChamCongTable.id} = ?',
      whereArgs: [idBangChamCong],
      limit: 1,
    );
    if (result.isEmpty) {
      return false;
    }
    return result.first[ChamCongTable.daKhoa] == TrangThaiKhoaChamCong.dakhoa.value;
  }
}
