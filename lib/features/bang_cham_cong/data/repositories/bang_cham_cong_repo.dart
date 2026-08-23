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

  Future<void> setKhoaChamCong( {int? idBangChamCong, int? idCongTrinh, int? thang, int? nam, required bool daKhoa} ) async
    {
          final db = await _dbHelper.database;
          final thangKey = '$nam-${thang.toString().padLeft(2, '0')}';
          final trangThai = daKhoa
              ? TrangThaiKhoaChamCong.dakhoa.value
              : TrangThaiKhoaChamCong.chuakhoa.value;

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

          final result = await db.query(
            ChamCongTable.tableName,
            columns: [ChamCongTable.id],
            where: '${ChamCongTable.idCongTrinh} = ? AND ${ChamCongTable.thang} = ?',
            whereArgs: [idCongTrinh, thangKey],
            limit: 1,
          );

          if (result.isNotEmpty) {
            await db.update(
              ChamCongTable.tableName,
              data,
              where: '${ChamCongTable.id} = ?',
              whereArgs: [result.first[ChamCongTable.id]],
            );
            return;
          }

          if (idCongTrinh == null || thang == null || nam == null) {
            throw ArgumentError(
              'idCongTrinh, thang, nam là bắt buộc khi không có idBangChamCong',
            );
          }
          await db.insert(
            ChamCongTable.tableName,
            BangChamCong(
              idCongTrinh: idCongTrinh,
              thang: thang,
              nam: nam,
              daKhoa: trangThai,
              ngayTao: DateTime.now().toIso8601String(),
              updatedAt: DateTime.now().toIso8601String(),
              isSynced: 0,
              isDeleted: 0,
            ).toMapInsert(),
          );
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

    return result.first[ChamCongTable.daKhoa] ==
        TrangThaiKhoaChamCong.dakhoa.value;
  }
}
