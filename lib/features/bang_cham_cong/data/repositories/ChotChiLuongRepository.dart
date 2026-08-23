import 'package:nhat_ky_xay_dung/core/utils/trang_thai_luong.dart';
import 'package:nhat_ky_xay_dung/data/tables/bang_luong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/models/bang_luong.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../data/_db_helper.dart';
import '../../../../data/db_helper.dart';

class ChotChiLuongRepository {
  final _dbHelper = DBHelper.instance;

  /// 👉 insert hoặc update bảng lương (chốt)
  Future<int> insertBangLuong(BangLuong bangLuong) async {
    final db = await _dbHelper.database;
    return await db.insert(BangLuongTable.tableName, bangLuong.toMapInsert());
  }
  Future<void> updateBangLuong(BangLuong bangLuong) async {
    final db = await _dbHelper.database;
    await db.update(
      BangLuongTable.tableName,
      bangLuong.toMapUpdate(),
      where: '${BangLuongTable.id} = ?',
      whereArgs: [bangLuong.id],
    );
  }
  Future<int> upsertBangLuong(BangLuong bangLuong) async
  {
    final db = await _dbHelper.database;
    // final data = {
    //   'idNhanVienCongTrinh': idNhanVienCongTrinh,
    //   'thang': thang,
    //   'nam': nam,
    //   'tongCong': tongCong,
    //   'tongLuong': tongLuong,
    //   'tongUng': tongUng,
    //   'thucNhan': thucNhan,
    // };
    final existing = await db.query(BangLuongTable.tableName,
      where: '${BangLuongTable.idNhanVienCongTrinh} = ? AND ${BangLuongTable.idBangChamCong}',
      whereArgs: [bangLuong.idNhanVienCongTrinh, bangLuong.idBangChamCong],
    );
    if (existing.isNotEmpty) {
      final id = existing.first[BangLuongTable.id] as int;
      await db.update(
        BangLuongTable.tableName,
        bangLuong.toMapUpdate(),
        where: '${BangLuongTable.id} = ?',
        whereArgs: [id],
      );
      return id;
    } else {
      return await insertBangLuong(bangLuong);
    }
  }
  Future<void> chotLuong(int id) async
  {
    final db = await _dbHelper.database;
    await db.update(
      BangLuongTable.tableName,
      {
        BangLuongTable.trangThai: TrangThaiLuong.dachot.value,
        BangLuongTable.ngayChot: DateTime.now().toIso8601String(),
      },
      where: '${BangLuongTable.id} = ?',
      whereArgs: [id],
    );
  }
  Future<void> huyChot(int id) async
  {
    final db = await _dbHelper.database;
    await db.update(
      BangLuongTable.tableName,
      {
        BangLuongTable.trangThai: TrangThaiLuong.chuachot.value,
        BangLuongTable.ngayChot: null,
      },
      where: '${BangLuongTable.id} = ?',
      whereArgs: [id],
    );
  }

  /// 👉 lấy bảng lương đã chốt
  Future<Map<String, dynamic>?> getBangLuong(int idNvct, int idBangChamCong) async
  {
    final db = await _dbHelper.database;
    final result = await db.query(
      BangLuongTable.tableName,
      where: '${BangLuongTable.idNhanVienCongTrinh} = ? AND ${BangLuongTable.idBangChamCong} = ? AND trangThai',
      whereArgs: [idNvct, idBangChamCong, TrangThaiLuong.dachot],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return result.first;
  }

  /// 👉 thêm chi lương
  Future<void> insertChiLuong({
    required int idBangLuong,
    required double soTien,
    String? ghiChu,
  }) async
  {
    final db = await _dbHelper.database;
    await db.insert('chi_luong', {
      'idBangLuong': idBangLuong,
      'soTien': soTien,
      'ngayChi': DateTime.now().toIso8601String(),
      'ghiChu': ghiChu,
    });
  }

  Future<Set<int>> getDanhSachDaChot( int idCongTrinh, int idBangChamCong) async
  {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
    SELECT ${BangLuongTable.idNhanVienCongTrinh}
    FROM ${BangLuongTable.tableName}
    WHERE ${BangLuongTable.idBangChamCong} = ?
  ''', [idBangChamCong]);
    return result
        .map((e) => (e['${BangLuongTable.idNhanVienCongTrinh}'] as num).toInt())
        .toSet();
  }
  /// 👉 tổng đã chi
  Future<double> getTongDaChi(int idBangLuong) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(soTien) as tong
      FROM chi_luong
      WHERE idBangLuong = ?
    ''', [idBangLuong]);

    return (result.first['tong'] as num?)?.toDouble() ?? 0;
  }

  Future<List<Map<String, dynamic>>> getBangLuongByCongTrinh( int idCongTrinh, int idBangChamCong) async
  {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
    SELECT bl.*, nvct.idCongTrinh
    FROM ${BangLuongTable.tableName} bl
    INNER JOIN ${NhanVienCongTrinhTable.tableName} nvct
      ON bl.idNhanVienCongTrinh = nvct.id
    WHERE nvct.idCongTrinh = ?
      AND bl.${BangLuongTable.idBangChamCong} = ?
  ''', [idCongTrinh, idBangChamCong]);
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'bang_luong',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> checkDaChotLuong(int idBangChamCong, int idNhanVienCongTrinh) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'bang_luong',
      where: 'idNhanVienCongTrinh = ? AND ${BangLuongTable.idBangChamCong} = ? AND trangThai = ?',
      whereArgs: [
        idNhanVienCongTrinh,
        idBangChamCong,
        TrangThaiLuong.dachot.value
      ],
    );
    return result.isNotEmpty;
  }

  Future<bool> tonTaiDaChotLuong(int? idBangChamCong) async {
    final db = await _dbHelper.database;
    final result = await db.query(
        'bang_luong',
        where: '${BangLuongTable.idBangChamCong} = ? AND trangThai = ?',
        whereArgs: [idBangChamCong, TrangThaiLuong.dachot.value]
    );
    if (result.isEmpty) return false;
    return true;
  }
}