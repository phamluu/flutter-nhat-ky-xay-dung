import 'package:nhat_ky_xay_dung/core/utils/trang_thai_luong.dart';
import 'package:nhat_ky_xay_dung/data/tables/luong_co_ban_table.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../data/db_helper.dart';
import '../../../../data/tables/ky_luong_chi_tiet_table.dart';
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
    bool isLuongBiKhoa = await isLuongCoBanBiKhoa(luong.ngayApDung, luong.idNhanVien!);
    if(isLuongBiKhoa){
      throw Exception('Không được thêm lương cơ bản áp dụng vào trong hoặc trước kỳ lương đã chốt');
    }
    final db = await _dbHelper.database;
    return await db.insert(LuongCoBanTable.tableName, luong.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(Luongcoban luong) async {
    final db = await _dbHelper.database;
    // Kiểm tra nếu lương cơ bản đã áp dụng trong chốt lương => không được sửa
    if(luong.id == null){
      throw Exception('Không tồn tại lương cơ bản');
    }
    bool isLuongDaChot = await isLuongCoBanDaChot(idLuongCoBan: luong.id!);
    if(isLuongDaChot){
      throw Exception('Không thể sửa mức lương đã được áp dụng trong kỳ lương đã chốt');
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
    bool isLuongDaChot = await isLuongCoBanDaChot(idLuongCoBan: id);
    if(isLuongDaChot){
      throw Exception('Không thể xóa mức lương đã được áp dụng trong kỳ lương đã chốt');
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

  // Không cho sửa/xóa lương đã được áp dụng vào kì lương đã chốt
  Future<bool> isLuongCoBanDaChot({ required int idLuongCoBan,}) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
    SELECT 1
    FROM ${KyLuongChiTietTable.tableName} klct
    INNER JOIN ${KyLuongTable.tableName} kl
      ON kl.${KyLuongTable.id} = klct.${KyLuongChiTietTable.idKyLuong}
    WHERE klct.${KyLuongChiTietTable.idLuongCoBan} = ?
      AND kl.${KyLuongTable.trangThai} = ?
      AND kl.${KyLuongTable.is_deleted} = 0
      AND klct.${KyLuongChiTietTable.isDeleted} = 0
    LIMIT 1
  ''', [
      idLuongCoBan,
      TrangThaiLuong.dachot.value,
    ]);
    return result.isNotEmpty;
  }

  // Không cho thêm mức lương của nv áp dụng vào trước kỳ lương đã chốt
  Future<bool> isLuongCoBanBiKhoa(String? ngayApDung, int idNhanVien) async{
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT 1
      FROM ${KyLuongTable.tableName} kl
      INNER JOIN ${ChamCongTable.tableName} cc on kl.${KyLuongTable.idBangChamCong} = cc.${ChamCongTable.id}
      INNER JOIN ${NhanVienCongTrinhTable.tableName} nvct on kl.${KyLuongTable.idNhanVienCongTrinh} == nvct.${NhanVienCongTrinhTable.id}
      WHERE kl.${KyLuongTable.trangThai} = ?
            AND kl.${KyLuongTable.is_deleted} = 0
            AND NVCT.${NhanVienCongTrinhTable.idNhanVien} = ?
             -- ngày áp dụng nằm trong hoặc trước kỳ đã chốt
            AND date(?) <= date(
              cc.${ChamCongTable.thang} || '-01',
              '+1 month',
              '-1 day'
            )
        LIMIT 1
    ''',[
      TrangThaiLuong.dachot.value,
      idNhanVien,
      ngayApDung
    ]);
    return result.isNotEmpty;
  }
}
