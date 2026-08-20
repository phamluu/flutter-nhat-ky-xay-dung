import 'package:nhat_ky_xay_dung/features/nhan_vien/data/models/NhanVien.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../data/_db_helper.dart';
import '../../../../data/db_helper.dart';
import '../../../cong_trinh/data/models/CongTrinh.dart';
import '../models/NhanVienCongTrinh.dart';

class NhanVienCongTrinhService {
  final _dbHelper = DBHelper.instance;

  Future<int> insert(NhanVienCongTrinh item) async {
    final db = await _dbHelper.database;
    return await db.insert('nhan_vien_cong_trinh', item.toMap());
  }

  Future<int> update(NhanVienCongTrinh item) async {
    final db = await _dbHelper.database;
    return await db.update(
      'nhan_vien_cong_trinh',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'nhan_vien_cong_trinh',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<NhanVienCongTrinh?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'nhan_vien_cong_trinh',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return NhanVienCongTrinh.fromMap(maps.first);
    return null;
  }

  Future<List<NhanVienCongTrinh>> getAll() async {
    final db = await _dbHelper.database;

    final maps = await db.rawQuery('''
    SELECT nvct.*,
           nv.id AS nv_id, nv.ho_ten AS nv_ten, nv.so_dien_thoai AS nv_sdt,
           ct.id AS ct_id, ct.ten AS ct_ten, ct.dia_chi AS ct_diaChi
    FROM nhan_vien_cong_trinh nvct
    LEFT JOIN nhan_vien nv ON nvct.idNhanVien = nv.id
    LEFT JOIN cong_trinh ct ON nvct.idCongTrinh = ct.id
    ORDER BY nvct.id DESC
  ''');

    return maps.map((e) {
      final nhanVien = e['nv_id'] != null
          ? NhanVien(
        id: e['nv_id'] as int,
        hoTen: e['nv_ten'] as String,
        soDienThoai: e['nv_sdt'] as String?,
      )
          : null;

      final congTrinh = e['ct_id'] != null
          ? CongTrinh(
        id: e['ct_id'] as int,
        ten: e['ct_ten'] as String,
        diaChi: e['ct_diaChi'] as String?,
      )
          : null;

      return NhanVienCongTrinh.fromMap(
        e,
        nhanVien: nhanVien,
        congTrinh: congTrinh,
      );
    }).toList();
  }


  Future<List<NhanVienCongTrinh>> getByNhanVien(int idNhanVien) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'nhan_vien_cong_trinh',
      where: 'idNhanVien = ?',
      whereArgs: [idNhanVien],
    );
    return maps.map((e) => NhanVienCongTrinh.fromMap(e)).toList();
  }

  Future<List<NhanVienCongTrinh>> getByCongTrinh(int? idCongTrinh) async {
    final db = await _dbHelper.database;

    // 1. Lấy tất cả công trình
    final congTrinhMaps = await db.query('cong_trinh');
    final congTrinhList = congTrinhMaps.map((e) => CongTrinh.fromMap(e)).toList();
    final congTrinhMap = {for (var c in congTrinhList) c.id: c};

    //2. Lấy tất cả nhân viên
    final nhanVienMaps = await db.query('nhan_vien');
    final nhanVienList = nhanVienMaps.map((e) => NhanVien.fromMap(e)).toList();
    final nhanVienMap = {for (var c in nhanVienList) c.id: c};

    List<Map<String, dynamic>> maps;
    if (idCongTrinh != null) {
      maps = await db.query(
        'nhan_vien_cong_trinh',
        where: 'idCongTrinh = ?',
        whereArgs: [idCongTrinh]
      );
    } else {
      maps = await db.query(
        'nhan_vien_cong_trinh'
      );
    }
    // 3. Map idCongTrinh sang CongTrinh
    return maps.map((e) {
      final ct = congTrinhMap[e['idCongTrinh']];
      final nv = nhanVienMap[e['idNhanVien']];
      return NhanVienCongTrinh.fromMap(e, congTrinh: ct, nhanVien: nv);
    }).toList();
  }
}
