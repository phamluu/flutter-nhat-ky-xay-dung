import 'package:nhat_ky_xay_dung/data/tables/bang_luong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/chi_luong_table.dart';

import '../../../../data/db_helper.dart';
import '../models/ChiLuong.dart';

class ChiLuongRepository {
  final _dbHelper = DBHelper.instance;
  Future<int> insert(ChiLuongModel model) async {
    final db = await _dbHelper.database;
    return await db.insert(ChiLuongTable.tableName, model.toMap());
  }
  Future<List<Map<String, dynamic>>> getChiLuong({
    required int idCongTrinh,
    DateTime? tuNgay,
    DateTime? denNgay,
  }) async {
    final db = await DBHelper.instance.database;

    final conditions = <String>[
      'nvc.idCongTrinh = ?',
      'cl.is_deleted = 0',
      'bl.is_deleted = 0',
      'nvc.is_deleted = 0',
    ];
    final args = <dynamic>[idCongTrinh];
    // Từ ngày
    if (tuNgay != null) {
      conditions.add('cl.ngayChi >= ?');
      args.add(tuNgay.toIso8601String());
    }
    // Đến ngày
    if (denNgay != null) {
      // Nếu denNgay chỉ có ngày (00:00:00), lấy đến hết ngày đó.
      final denNgayCuoi = DateTime(
        denNgay.year,
        denNgay.month,
        denNgay.day,
        23,
        59,
        59,
        999,
      );
      conditions.add('cl.ngayChi <= ?');
      args.add(denNgayCuoi.toIso8601String());
    }
    final sql = '''
    SELECT
      cl.id,
      cl.idBangLuong,
      cl.soTien,
      cl.ngayChi,
      cl.ghiChu,
      cl.createdAt,
      cl.server_id,
      cl.is_synced,
      cl.updated_at,

      bl.idNhanVienCongTrinh,
      bl.${BangLuongTable.idBangChamCong},
      bl.tongCong,
      bl.tongLuong,
      bl.tongUng,
      bl.thucNhan,
      bl.trangThai,
      bl.ngayChot,

      nvc.idNhanVien,
      nvc.idCongTrinh,
      nvc.ngayBatDau,
      nvc.ngayKetThuc,
      nvc.vaiTro

    FROM chi_luong cl

    INNER JOIN bang_luong bl
      ON bl.id = cl.idBangLuong

    INNER JOIN nhan_vien_cong_trinh nvc
      ON nvc.id = bl.idNhanVienCongTrinh

    WHERE ${conditions.join(' AND ')}

    ORDER BY cl.ngayChi DESC, cl.id DESC
  ''';

    return await db.rawQuery(sql, args);
  }
  Future<List<ChiLuongModel>> getByBangLuong(int idBangLuong) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'chi_luong',
      where: 'idBangLuong = ?',
      whereArgs: [idBangLuong],
      orderBy: 'ngayChi DESC',
    );
    return result.map((e) => ChiLuongModel.fromMap(e)).toList();
  }
  Future<List<ChiLuongModel>> getByCongTrinhThangNamWithNhanVien(
      int idCongTrinh, {String? kyLuong, int? idBangChamCong}) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
    SELECT 
      cl.*,
      nv.ho_ten AS tenNhanVien
    FROM chi_luong cl
    INNER JOIN bang_luong bl ON cl.idBangLuong = bl.id
    INNER JOIN nhan_vien_cong_trinh nvct 
        ON bl.idNhanVienCongTrinh = nvct.id
    INNER JOIN nhan_vien nv 
        ON nvct.idNhanVien = nv.id
    WHERE nvct.idCongTrinh = ?
      AND bl.${BangLuongTable.idBangChamCong} = ?
    ORDER BY cl.ngayChi DESC
  ''', [idCongTrinh, idBangChamCong]);
    return result.map((e) => ChiLuongModel.fromMap(e)).toList();
  }
  Future<double> getTongDaChi(int idBangLuong) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(soTien) as total FROM chi_luong WHERE idBangLuong = ?',
      [idBangLuong],
    );
    final value = result.first['total'];
    return (value as num?)?.toDouble() ?? 0;
  }
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'chi_luong',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}