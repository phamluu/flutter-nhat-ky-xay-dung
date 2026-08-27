import 'package:nhat_ky_xay_dung/core/utils/trang_thai_luong.dart';
import 'package:nhat_ky_xay_dung/data/tables/luong_co_ban_table.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../data/db_helper.dart';
import '../../../../data/tables/bang_luong_table.dart';
import '../../../../data/tables/cham_cong_table.dart';
import '../../../../data/tables/nhan_vien_cong_trinh_table.dart';
import '../../../../data/tables/nhan_vien_table.dart';
import '../../../nhan_vien/data/services/nhan_vien_service.dart';
import '../models/LuongCoBan.dart';

class LuongCoBanRepository {
  final DBHelper _dbHelper = DBHelper.instance;
  // Lương cơ bản nào đã được áp dụng trong bảng chấm công đã chốt => không được xóa sửa
  Future<int> insert(Luongcoban luong) async {
    final db = await _dbHelper.database;
    return await db.insert(LuongCoBanTable.tableName, luong.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(Luongcoban luong) async {
    final db = await _dbHelper.database;
    return await db.update(
      LuongCoBanTable.tableName,
      luong.toMap(),
      where: '${LuongCoBanTable.id} = ?',
      whereArgs: [luong.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(LuongCoBanTable.tableName, where: '${LuongCoBanTable.id} = ?', whereArgs: [id]);
  }

  Future<Luongcoban?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(LuongCoBanTable.tableName, where: '${LuongCoBanTable.id} = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Luongcoban.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Luongcoban>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(LuongCoBanTable.tableName, orderBy: "${LuongCoBanTable.ngayApDung} DESC");
    final nhanViens = await NhanVienService().getAllNhanVien();
    return List.generate(maps.length, (i) {
      return Luongcoban.fromMap(maps[i], nhanViens: nhanViens);
    });
  }

  Future<List<Luongcoban>> getByNhanVien(int idNhanVien) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      LuongCoBanTable.tableName,
      where: '${LuongCoBanTable.idNhanVien} = ?',
      whereArgs: [idNhanVien],
      orderBy: '${LuongCoBanTable.ngayApDung} DESC',
    );

    return List.generate(maps.length, (i) {
      return Luongcoban.fromMap(maps[i]);
    });
  }

  // Không cho sửa/xóa lương đã được áp dụng vào kì lương đã chốt
  // Tìm danh sách idLuongCoBan đã áp dụng trong chấm công chi tiết với bảng lương đã chốt
  Future<List<int>> getIdLuongCoBanDaChot() async {
    final db = await _dbHelper.database;
    // Lấy danh sách id của bảng lương đã chốt
    final idLuongChots = await db.query(
      BangLuongTable.tableName,
      columns:  ['${BangLuongTable.id}'],
      where: '${BangLuongTable.trangThai} = ${TrangThaiLuong.dachot.value}',
      orderBy: '${LuongCoBanTable.ngayApDung} DESC',
    );
    // Lấy danh sách chấm công ngày lương thuộc idLuongChots
    return [];
  }
  Future<bool> isLuongCoBanDaChot(int idLuongCoBan) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
    SELECT 1
    FROM ${LuongCoBanTable.tableName} l
    INNER JOIN ${NhanVienCongTrinhTable.tableName} nvc
      ON nvc.${NhanVienCongTrinhTable.idNhanVien}
       = l.${LuongCoBanTable.idNhanVien}
    INNER JOIN ${BangLuongTable.tableName} bl
      ON bl.${BangLuongTable.idNhanVienCongTrinh}
       = nvc.${NhanVienCongTrinhTable.id}
    INNER JOIN ${ChamCongTable.tableName} cc
      ON cc.${ChamCongTable.id}
       = bl.${BangLuongTable.idBangChamCong}
    WHERE l.${LuongCoBanTable.id} = ?
      AND bl.${BangLuongTable.trangThai} >= 1
      AND l.${LuongCoBanTable.ngayApDung} >= cc.${ChamCongTable.thang} || '-01'
      AND l.${LuongCoBanTable.ngayApDung} < date(
        cc.${ChamCongTable.thang} || '-01',
        '+1 month'
      )
    LIMIT 1
  ''', [idLuongCoBan]);
    return result.isNotEmpty;
  }

  Future<bool> isNgayApDungLuongDaChot(int idNhanVien,DateTime ngayApDung,) async {
    final db = await _dbHelper.database;
    final ngay = ngayApDung.toIso8601String().substring(0, 10);
    final result = await db.rawQuery('''
    SELECT 1
    FROM ${NhanVienCongTrinhTable.tableName} nvc
    INNER JOIN ${BangLuongTable.tableName} bl
      ON bl.${BangLuongTable.idNhanVienCongTrinh}
       = nvc.${NhanVienCongTrinhTable.id}
    INNER JOIN ${ChamCongTable.tableName} cc
      ON cc.${ChamCongTable.id}
       = bl.${BangLuongTable.idBangChamCong}
    WHERE nvc.${NhanVienCongTrinhTable.idNhanVien} = ?
      AND bl.${BangLuongTable.trangThai} >= 1
      AND ? >= cc.${ChamCongTable.thang} || '-01'
      AND ? < date(
        cc.${ChamCongTable.thang} || '-01',
        '+1 month'
      )
    LIMIT 1
  ''', [
      idNhanVien,
      ngay,
      ngay,
    ]);
    return result.isNotEmpty;
  }
}
