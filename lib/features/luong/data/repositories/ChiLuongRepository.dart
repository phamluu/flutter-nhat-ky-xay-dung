import 'package:nhat_ky_xay_dung/data/tables/ky_luong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/chi_luong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_table.dart';

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
      'nvc.${NhanVienCongTrinhTable.idCongTrinh} = ?',
      'cl.${ChiLuongTable.is_deleted} = 0',
      'bl.${KyLuongTable.is_deleted} = 0',
      'nvc.${NhanVienCongTrinhTable.isDeleted} = 0',
    ];
    final args = <dynamic>[idCongTrinh];
    // Từ ngày
    if (tuNgay != null) {
      conditions.add('cl.${ChiLuongTable.ngayChi} >= ?');
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
      conditions.add('cl.${ChiLuongTable.ngayChi} <= ?');
      args.add(denNgayCuoi.toIso8601String());
    }
    final sql = '''
    SELECT
      cl.${ChiLuongTable.id},
      cl.${ChiLuongTable.idBangLuong},
      cl.${ChiLuongTable.soTien},
      cl.${ChiLuongTable.ngayChi},
      cl.${ChiLuongTable.ghiChu},
      cl.${ChiLuongTable.createdAt},
      cl.${ChiLuongTable.server_id},
      cl.${ChiLuongTable.is_synced},
      cl.${ChiLuongTable.updated_at},

      bl.${KyLuongTable.idNhanVienCongTrinh},
      bl.${KyLuongTable.idBangChamCong},
      bl.${KyLuongTable.tongCong},
      bl.${KyLuongTable.tongLuong},
      bl.${KyLuongTable.tongUng},
      bl.${KyLuongTable.thucNhan},
      bl.${KyLuongTable.trangThai},
      bl.${KyLuongTable.ngayChot},

      nvc.${NhanVienCongTrinhTable.idNhanVien},
      nvc.${NhanVienCongTrinhTable.idCongTrinh},
      nvc.${NhanVienCongTrinhTable.ngayBatDau},
      nvc.${NhanVienCongTrinhTable.ngayKetThuc},
      nvc.${NhanVienCongTrinhTable.vaiTro}

    FROM ${ChiLuongTable.tableName} cl

    INNER JOIN ${KyLuongTable.tableName} bl
      ON bl.${KyLuongTable.id} = cl.${ChiLuongTable.idBangLuong}

    INNER JOIN ${NhanVienCongTrinhTable.tableName} nvc
      ON nvc.id = bl.${KyLuongTable.idNhanVienCongTrinh}

    WHERE ${conditions.join(' AND ')}

    ORDER BY cl.${ChiLuongTable.ngayChi} DESC, cl.${ChiLuongTable.id} DESC
  ''';
    return await db.rawQuery(sql, args);
  }
  Future<List<ChiLuongModel>> getByBangLuong(int? idBangLuong) async {
    if (idBangLuong == null){
      return [];
    }
    final db = await _dbHelper.database;
    final result = await db.query(
      ChiLuongTable.tableName,
      where: '${ChiLuongTable.idBangLuong} = ?',
      whereArgs: [idBangLuong],
      orderBy: '${ChiLuongTable.ngayChi} DESC',
    );
    return result.map((e) => ChiLuongModel.fromMap(e)).toList();
  }
  Future<List<ChiLuongModel>> getByCongTrinhThangNamWithNhanVien(
      int idCongTrinh, {String? kyLuong, int? idBangChamCong}) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
    SELECT 
      cl.*,
      nv.${NhanVienTable.hoTen} AS tenNhanVien
    FROM ${ChiLuongTable.tableName} cl
    INNER JOIN ${KyLuongTable.tableName} bl ON cl.${ChiLuongTable.idBangLuong} = bl.${KyLuongTable.id}
    INNER JOIN ${NhanVienCongTrinhTable.tableName} nvct 
        ON bl.${KyLuongTable.idNhanVienCongTrinh} = nvct.${NhanVienCongTrinhTable.id}
    INNER JOIN ${NhanVienTable.tableName} nv 
        ON nvct.${NhanVienCongTrinhTable.idNhanVien} = nv.${NhanVienTable.id}
    WHERE nvct.${NhanVienCongTrinhTable.idCongTrinh} = ?
      AND bl.${KyLuongTable.idBangChamCong} = ?
    ORDER BY cl.${ChiLuongTable.ngayChi} DESC
  ''', [idCongTrinh, idBangChamCong]);
    return result.map((e) => ChiLuongModel.fromMap(e)).toList();
  }
  Future<double> getTongDaChi(int? idBangLuong) async {
    if(idBangLuong == null){
      throw Exception('Không có bảng lương');
    }
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(${ChiLuongTable.soTien}) as total FROM ${ChiLuongTable.tableName} WHERE ${ChiLuongTable.idBangLuong}= ?',
      [idBangLuong],
    );
    final value = result.first['total'];
    return (value as num?)?.toDouble() ?? 0;
  }
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      ChiLuongTable.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}