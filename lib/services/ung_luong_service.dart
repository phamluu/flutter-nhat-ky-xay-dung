import 'package:sqflite/sqflite.dart';

import '../data/db_helper.dart';
import '../data/models/CongTrinh.dart';
import '../data/models/NhanVienCongTrinh.dart';
import '../data/models/UngLuong.dart';
import 'cong_trinh_service.dart';
import 'nhan_vien_cong_trinh_service.dart';
import 'nhan_vien_service.dart';

class UngLuongService {
  final _dbHelper = DBHelper.instance;

  Future<List<Ungluong>> getUngLuongCongTrinh([int? idCongTrinh]) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      '''
    SELECT ul.*, 
           nvct.id AS nvct_id, 
           nvct.idNhanVien AS nvct_idNhanVien, 
           nvct.idCongTrinh AS nvct_idCongTrinh,
           ct.id AS congTrinhId,
           ct.ten AS congTrinhTen
    FROM ung_luong ul 
    LEFT JOIN nhan_vien_cong_trinh nvct ON ul.idNhanVienCongTrinh = nvct.id
    LEFT JOIN cong_trinh ct ON nvct.idCongTrinh = ct.id
    ${idCongTrinh != null ? "WHERE nvct.idCongTrinh = ?" : ""}
    ORDER BY ul.ngayUng DESC
    ''',
      idCongTrinh != null ? [idCongTrinh] : [],
    );

    // load nhân viên
    final nhanVienService = NhanVienService();
    final nhanViens = await nhanVienService.getAllNhanVien();

    return result.map((e) {
      // map CongTrinh (nếu có)
      CongTrinh? congTrinh;
      if (e['congTrinhId'] != null) {
        congTrinh = CongTrinh(
          id: e['congTrinhId'] as int,
          ten: e['congTrinhTen'] as String,
        );
      }

      // map NhanVienCongTrinh (nếu có)
      NhanVienCongTrinh? nvct;
      if (e['nvct_id'] != null) {
        nvct = NhanVienCongTrinh(
          id: e['nvct_id'] as int,
          idNhanVien: e['nvct_idNhanVien'] as int,
          idCongTrinh: e['nvct_idCongTrinh'] as int?,
          congTrinh: congTrinh,
        );
      }

      return Ungluong.fromMap(
        e,
        nhanViens: nhanViens,
        nhanVienCongTrinhs: nvct != null ? [nvct] : [],
        congTrinhs: congTrinh != null ? [congTrinh] : [],
      );
    }).toList();

  }




  Future<List<Ungluong>> getAllUngLuong() async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'ung_luong',
      orderBy: 'ngayUng DESC',
    );

    // load nhân viên
    final nhanVienService = NhanVienService();
    final nhanViens = await nhanVienService.getAllNhanVien();

    // load nhân viên công trình
    final nvctService = NhanVienCongTrinhService();
    final nhanVienCongTrinhs = await nvctService.getAll();

    // load công trình
    final congTrinhService = CongTrinhService();
    final congTrinhs = await congTrinhService.getDanhSachCongTrinh();

    return result.map((e) => Ungluong.fromMap(
      e,
      nhanViens: nhanViens,
      nhanVienCongTrinhs: nhanVienCongTrinhs,
      congTrinhs: congTrinhs,
    )).toList();
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
