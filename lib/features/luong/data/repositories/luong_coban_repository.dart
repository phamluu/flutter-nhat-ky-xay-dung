import 'package:nhat_ky_xay_dung/core/utils/trang_thai_luong.dart';
import 'package:nhat_ky_xay_dung/data/tables/luong_co_ban_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/phien_chot_cong_table.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../data/db_helper.dart';
import '../../../../data/tables/ky_luong_table.dart';
import '../../../../data/tables/cham_cong_table.dart';
import '../../../../data/tables/nhan_vien_cong_trinh_table.dart';
import '../../../../data/tables/nhan_vien_table.dart';
import '../../../nhan_vien/data/services/nhan_vien_service.dart';
import '../models/LuongCoBan.dart';

class LuongCoBanRepository {
  final DBHelper _dbHelper = DBHelper.instance;
  // Lương cơ bản nào đã được áp dụng trong bảng chấm công đã chốt => không được xóa sửa
  Future<int> insert(Luongcoban luong) async {
    if(luong.ngayApDung == null || luong.idNhanVien == null){
      throw Exception('Chưa có ngày áp dụng hoặc nhân viên');
    }
    bool isLuongDaChot = await isLuongCoBanDaChot(idNhanVien: luong.idNhanVien, ngayApDung: luong.ngayApDung);
    if(isLuongDaChot){
      throw Exception('Không thể thêm lương cơ bản trong kỳ lương đã chốt');
    }
    try{
      final db = await _dbHelper.database;
      return await db.insert(LuongCoBanTable.tableName, luong.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }catch(e){
      throw Exception('Lỗi');
    }
  }

  Future<int> update(Luongcoban luong) async {
    final db = await _dbHelper.database;
    // Kiểm tra nếu lương cơ bản đã áp dụng trong chốt lương => không được sửa
    if(luong.id == null){
      throw Exception('Không tồn tại lương cơ bản');
    }
    bool isLuongDaChot = await isLuongCoBanDaChot(idNhanVien: luong.idNhanVien, ngayApDung: luong.ngayApDung);
    if(isLuongDaChot){
      throw Exception('Không thể sửa mức lương trong kỳ lương đã chốt');
    }
    return await db.update(
      LuongCoBanTable.tableName,
      luong.toMap(),
      where: '${LuongCoBanTable.id} = ?',
      whereArgs: [luong.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    final rs = await db.query(LuongCoBanTable.tableName,
        where: '${LuongCoBanTable.id}',
        whereArgs: [id], limit: 1);
    if(rs.isEmpty){
      throw Exception('Không tồn tại lương cơ bản');
    }
    final int? idNhanVien = rs.first[LuongCoBanTable.idNhanVien] as int?;
    final String? ngayApDung = rs.first[LuongCoBanTable.ngayApDung] as String?;
    bool isLuongDaChot = await isLuongCoBanDaChot(idNhanVien: idNhanVien, ngayApDung: ngayApDung);
    if(isLuongDaChot){
      throw Exception('Không thể xóa mức lương trong kỳ lương đã chốt');
    }
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

  // Không cho thêm/sửa/xóa mức lương áp dụng trong và trước kì lương đã chốt
  Future<bool> isLuongCoBanDaChot({ String? ngayApDung, int? idNhanVien}) async {
    final db = await _dbHelper.database;
    final rs = await db.rawQuery('''
    SELECT * FROM ${KyLuongTable.tableName} kl
    INNER JOIN ${NhanVienCongTrinhTable.tableName} nvct on kl.${KyLuongTable.idNhanVienCongTrinh} = nvct.${NhanVienCongTrinhTable.id}
    INNER JOIN ${PhienChotCongTable.tableName} pc on kl.${KyLuongTable.idPhienChot} = pc.${PhienChotCongTable.id}
    WHERE nvct.${NhanVienCongTrinhTable.idNhanVien} = ? AND date(${PhienChotCongTable.ngayChot}) >= date(?)
    AND kl.${KyLuongTable.trangThai} = ${TrangThaiLuong.dachot.value}
    ''',[idNhanVien, ngayApDung]
    );
    return rs.isNotEmpty;
  }

}
