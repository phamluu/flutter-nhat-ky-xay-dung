import 'package:sqflite/sqflite.dart';

import '../data/db_helper.dart';
import '../data/models/UngLuong.dart';
import 'nhan_vien_service.dart';

class UngLuongService {
  final _dbHelper = DBHelper.instance;

  Future<List<Ungluong>> getUngLuongCongTrinh([int? idCongTrinh]) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      '''
    SELECT ul.*, nvct.id AS nvct_id, nvct.idNhanVien, nvct.idCongTrinh
    FROM ung_luong ul 
    LEFT JOIN nhan_vien_cong_trinh nvct ON ul.idNhanVienCongTrinh = nvct.id
    ${idCongTrinh != null ? "WHERE nvct.idCongTrinh = ?" : ""}
    ORDER BY ul.ngayUng DESC
    ''',
      idCongTrinh != null ? [idCongTrinh] : [],
    );

    // load nhân viên ở đây
    final nhanVienService = NhanVienService();
    final nhanViens = await nhanVienService.getAllNhanVien();

    return result
        .map((e) => Ungluong.fromMap(e, nhanViens: nhanViens))
        .toList();
  }



  Future<List<Ungluong>> getAllUngLuong() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'ung_luong',
      orderBy: 'ngayUng DESC',
    );
    // load nhân viên ở đây
    final nhanVienService = NhanVienService();
    final nhanViens = await nhanVienService.getAllNhanVien();

    return result.map((e) => Ungluong.fromMap(e, nhanViens: nhanViens)).toList();
  }

  // Thêm ứng lương
  Future<int> addUngLuong(Ungluong u) async {
    final db = await _dbHelper.database;
    return await db.insert('ung_luong', u.toMap());
  }

  // Sửa ứng lương
  Future<int> updateUngLuong(Ungluong u) async {
    final db = await _dbHelper.database;
    return await db.update(
      'ung_luong',
      u.toMap(),
      where: 'id = ?',
      whereArgs: [u.id],
    );
  }

  // Xóa ứng lương
  Future<int> deleteUngLuong(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'ung_luong',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
