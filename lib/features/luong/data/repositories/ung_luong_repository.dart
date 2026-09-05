import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/utils/trang_thai_luong.dart';
import 'package:nhat_ky_xay_dung/data/tables/cham_cong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/phien_chot_cong_table.dart';
import 'package:nhat_ky_xay_dung/features/luong/data/models/UngLuongDataModel.dart';
import 'package:path/path.dart';
import '../../../../data/db_helper.dart';
import '../../../../data/tables/ky_luong_table.dart';
import '../../../../data/tables/chi_tiet_doi_tru_ung_luong.dart';
import '../../../../data/tables/ung_luong_table.dart';
import '../models/ChiTietDoiUngTruLuong.dart';
import '../models/UngLuong.dart';
import '../enums.dart';
class UngLuongRepository {
  final _dbHelper = DBHelper.instance;
  // group theo nhân viên trong chi tiết công trình
  Future<List<Map<String, dynamic>>> getKyLuongs(int idCongTrinh) async {
    final db = await _dbHelper.database;
    final rs = await db.query(
      ChamCongTable.tableName,
      columns: [ChamCongTable.thang],
      where: '${ChamCongTable.idCongTrinh} = ?',
      whereArgs: [idCongTrinh],
      orderBy: '${ChamCongTable.thang} DESC',
    );
    return rs.map((item) {
      final thangKey = item[ChamCongTable.thang]?.toString();
      if (thangKey == null || !thangKey.contains('-')) {
        return {
          'value': null,
          'label': '',
        };
      }
      final parts = thangKey.split('-');
      final nam = int.tryParse(parts[0]);
      final thang = int.tryParse(parts[1]);
      return {
        'value': thangKey,
        'label': 'Kỳ lương tháng $thang năm $nam',
      };
    }).toList();
  }

  // Tổng ứng đã trừ khi chốt luong phiên này
  Future<double>tongTruUngForPhienChot(int? idPhienChot, int? idNhanVienCongTrinh) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
    SELECT COALESCE(
      SUM(${ChiTietDoiTruUngLuongTable.soTienDoiTru}),
      0
    ) AS total
    FROM ${ChiTietDoiTruUngLuongTable.tableName} ct
    INNER JOIN ${KyLuongTable.tableName} kl ON ct.${ChiTietDoiTruUngLuongTable.idBangLuong} = kl.${KyLuongTable.id}
    WHERE kl.${KyLuongTable.idPhienChot} = ? AND kl.${KyLuongTable.idNhanVienCongTrinh} = ? AND ${KyLuongTable.trangThai} = ${TrangThaiLuong.dachot.value}
  ''', [
      idPhienChot,
      idNhanVienCongTrinh,
    ]);

    return (result.first['total'] as num).toDouble();
  }
  // Tổng ứng còn lại chưa chốt phiên này
  Future<double>tongUngForPhienChot(int? idPhienChot, int? idNhanVienCongTrinh) async {
    final db = await _dbHelper.database;
    final rs = await db.rawQuery('''
    SELECT COALESCE(
      SUM(
        COALESCE(${UngLuongTable.soTien}, 0)
        -
        COALESCE(${UngLuongTable.soTienDaTru}, 0)
      ),
      0
    ) AS conLai
    FROM ${UngLuongTable.tableName}
    WHERE ${UngLuongTable.idNhanVienCongTrinh} = ?
  ''', [
      idNhanVienCongTrinh,
    ]);
    final conLai =
    (rs.first['conLai'] as num).toDouble();
    final daTruKyNay = await tongTruUngForPhienChot(
      idPhienChot,
      idNhanVienCongTrinh,
    );
    // Số dư ứng trước khi khấu trừ kỳ hiện tại
    return conLai + daTruKyNay;
  }
  // Tổng ứng đã trừ trong thời gian chấm công
  Future<double> tongTruUngForChamCong(int? idBangChamCong, int? idNhanVienCongTrinh,) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
    SELECT COALESCE(
      SUM(${ChiTietDoiTruUngLuongTable.soTienDoiTru}),
      0
    ) AS total
    FROM ${ChiTietDoiTruUngLuongTable.tableName} ct
    INNER JOIN ${KyLuongTable.tableName} kl
      ON ct.${ChiTietDoiTruUngLuongTable.idBangLuong}
       = kl.${KyLuongTable.id}
    INNER JOIN ${PhienChotCongTable.tableName} pc
      ON kl.${KyLuongTable.idPhienChot}
       = pc.${PhienChotCongTable.id}
    WHERE pc.${PhienChotCongTable.idChamCong} = ?
      AND kl.${KyLuongTable.idNhanVienCongTrinh} = ?
  ''', [
      idBangChamCong,
      idNhanVienCongTrinh,
    ]);

    return (result.first['total'] as num).toDouble();
  }

  // Tổng ứng còn lại trước khi khấu trừ kỳ này
  Future<double> tongUngForNhanVien( int? idBangChamCong, int? idNhanVienCongTrinh,) async {
    final db = await _dbHelper.database;
    final rs = await db.rawQuery('''
    SELECT COALESCE(
      SUM(
        COALESCE(${UngLuongTable.soTien}, 0)
        -
        COALESCE(${UngLuongTable.soTienDaTru}, 0)
      ),
      0
    ) AS conLai
    FROM ${UngLuongTable.tableName}
    WHERE ${UngLuongTable.idNhanVienCongTrinh} = ?
  ''', [
      idNhanVienCongTrinh,
    ]);
    final conLai =
    (rs.first['conLai'] as num).toDouble();
    final daTruKyNay = await tongTruUngForChamCong(
      idBangChamCong,
      idNhanVienCongTrinh,
    );
    // Số dư ứng trước khi khấu trừ kỳ hiện tại
    return conLai + daTruKyNay;
  }

  Future<List<UngLuongViewModel>> getDanhSach( int idCongTrinh, {int? thang,int? nam, String? kyLuong, }) async {
    final db = await _dbHelper.database;
    final ulWhere = <String>[];
    final ulArgs = <dynamic>[];
    if (kyLuong != null && kyLuong.isNotEmpty) {
      ulWhere.add(
        "strftime('%Y-%m', ul.ngayUng) = ?",
      );
      ulArgs.add(kyLuong);
    } else if (thang != null && nam != null) {
      ulWhere.add(
        "strftime('%m', ul.ngayUng) = ?",
      );
      ulArgs.add(
        thang.toString().padLeft(2, '0'),
      );
      ulWhere.add(
        "strftime('%Y', ul.ngayUng) = ?",
      );
      ulArgs.add(nam.toString());
    } else if (thang != null) {
      ulWhere.add(
        "strftime('%m', ul.ngayUng) = ?",
      );
      ulArgs.add(
        thang.toString().padLeft(2, '0'),
      );
    } else if (nam != null) {
      ulWhere.add(
        "strftime('%Y', ul.ngayUng) = ?",
      );
      ulArgs.add(nam.toString());
    }
    // Nếu có is_deleted
    ulWhere.add(
      'ul.${UngLuongTable.is_deleted} = 0',
    );
    final ulCondition = ulWhere.isEmpty
        ? ''
        : 'AND ${ulWhere.join(' AND ')}';
    // =========================
    // 2. Lấy nhân viên công trình
    //    + LEFT JOIN ứng lương
    // =========================
    final result = await db.rawQuery(
      '''
    SELECT
      nvct.${NhanVienCongTrinhTable.id}
        AS idNhanVienCongTrinh,
      nv.${NhanVienTable.hoTen}
        AS hoTen,
      ul.${UngLuongTable.id}
        AS idUngLuong,
      ul.${UngLuongTable.soTien}
        AS soTien,
      ul.${UngLuongTable.soTienDaTru}
        AS soTienDaTru,
      ul.${UngLuongTable.ngayUng}
        AS ngayUng,
      ul.${UngLuongTable.lyDo}
        AS lyDo
    FROM ${NhanVienCongTrinhTable.tableName} nvct
    INNER JOIN ${NhanVienTable.tableName} nv
      ON nv.${NhanVienTable.id}
       = nvct.${NhanVienCongTrinhTable.idNhanVien}

    LEFT JOIN ${UngLuongTable.tableName} ul
      ON ul.${UngLuongTable.idNhanVienCongTrinh}
       = nvct.${NhanVienCongTrinhTable.id}
      $ulCondition

    WHERE nvct.${NhanVienCongTrinhTable.idCongTrinh} = ?

    ORDER BY
      nv.${NhanVienTable.hoTen} ASC,
      ul.${UngLuongTable.ngayUng} DESC
    ''',
      [
        ...ulArgs,
        idCongTrinh,
      ],
    );

    // =========================
    // 3. Group theo nhân viên
    // =========================

    final Map<int, UngLuongViewModel> map = {};

    for (final row in result) {
      final idNVCT = row['idNhanVienCongTrinh'] as int?;
      if (idNVCT == null) {
        continue;
      }
      final viewModel = map.putIfAbsent(
        idNVCT,
            () => UngLuongViewModel(
          idNhanVienCongTrinh: idNVCT,
          hoTen: row['hoTen']?.toString(),
          thang: thang,
          nam: nam,
          daUngs: [],
        ),
      );

      // Nhân viên chưa có ứng lương
      // => idUngLuong = null
      // => giữ nguyên daUngs = []
      final idUngLuong = row['idUngLuong'];
      if (idUngLuong != null) {
        viewModel.daUngs!.add(
          UngLuongItem(
            soTien: ((row['soTien'] as num?) ?? 0).toDouble(),
            soTienDaTru: ((row['soTienDaTru'] as num?) ?? 0).toDouble(),
            ngayUng: row['ngayUng'] != null ? DateTime.tryParse( row['ngayUng'].toString(), )
                : null,
            lyDo: row['lyDo']?.toString(),
          ),
        );
      }
    }

    return map.values.toList();
  }

  // Danh sách ứng lương của 1 nhân viên
  Future<List<Ungluong>> getUngLuongNhanVien( int idNhanVienCongTrinh, { String? kyLuong, // Tháng trong bảng chấm công
        int? thang,
        int? nam,
      }) async {
    final db = await _dbHelper.database;
    final where = [
      '${UngLuongTable.idNhanVienCongTrinh} = ?',
    ];
    final whereArgs = <dynamic>[idNhanVienCongTrinh];
    if (kyLuong?.isNotEmpty == true) {
      where.add(
        "strftime('%Y-%m', ${UngLuongTable.ngayUng}) = ?",
      );
      whereArgs.add(kyLuong);
    }
    final result = await db.query(
      UngLuongTable.tableName,
      where: where.join(' AND '),
      whereArgs: whereArgs,
      orderBy: '${UngLuongTable.id} DESC',
    );
    final list = result.map(Ungluong.fromMap).toList();
    await Future.wait(
      list.map((item) async {
        item.lstDoiTru = await getDoiUngTruLuongs(item.id);
      }),
    );
    return list;
  }
  Future<List<ChiTietDoiUngTruLuong>> getDoiUngTruLuongs(int? idUngLuong,) async {
    if (idUngLuong == null) return [];
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
    SELECT 
      d.*,
      c.${ChamCongTable.thang} AS thangKey
    FROM ${ChiTietDoiTruUngLuongTable.tableName} d
    LEFT JOIN ${KyLuongTable.tableName} b ON b.${KyLuongTable.id} = d.${ChiTietDoiTruUngLuongTable.idBangLuong}
    LEFT JOIN ${PhienChotCongTable.tableName} pc on b.${KyLuongTable.idPhienChot} = pc.${PhienChotCongTable.id}
    LEFT JOIN ${ChamCongTable.tableName} c ON c.${ChamCongTable.id} = pc.${PhienChotCongTable.idChamCong}
    WHERE d.${ChiTietDoiTruUngLuongTable.idUngLuong} = ?
    ORDER BY d.${ChiTietDoiTruUngLuongTable.id} DESC
  ''', [idUngLuong]);
    return result.map((e) => ChiTietDoiUngTruLuong.fromMap(e)).toList();
  }


  // Map trong bảng chấm công
  Future<List<Map<String, dynamic>>> getUngLuong( {required int idCongTrinh, DateTime? tuNgay, DateTime? denNgay}) async
  {
    final db = await _dbHelper.database;
    String dateCondition = '';
    final args = <dynamic>[];
    if (tuNgay != null) {
      dateCondition += ' AND date(ul.${UngLuongTable.ngayUng}) >= date(?)';
      args.add(_formatDate(tuNgay));
    }
    if (denNgay != null) {
      dateCondition += ' AND date(ul.${UngLuongTable.ngayUng}) <= date(?)';
      args.add(_formatDate(denNgay));
    }
    args.add(idCongTrinh);
    return await db.rawQuery(
        ''' SELECT nvct.id AS idNhanVienCongTrinh,ul.${UngLuongTable.id} AS idUngLuong, ul.${UngLuongTable.soTien} FROM ${NhanVienCongTrinhTable.tableName} nvct LEFT JOIN ${UngLuongTable.tableName} ul ON ul.${UngLuongTable.idNhanVienCongTrinh} = nvct.${NhanVienCongTrinhTable.id} AND ul.${UngLuongTable.is_deleted} = 0 $dateCondition WHERE nvct.${NhanVienCongTrinhTable.idCongTrinh} = ? ORDER BY date(ul.${UngLuongTable.ngayUng}) DESC ''',
        args);
  }



  // lOAD DATA CHUNG CHO DANH SÁCH
  Future<List<UngLuongDataModel>> getUngLuongData({
    int? idCongTrinh,
    int? idNhanVienCongTrinh,
    DateTime? tuNgay,
    DateTime? denNgay,
    int? thang,
    int? nam,
    String? kyLuong,
    bool includeDeleted = false,
  }) async {
    final db = await _dbHelper.database;
    final where = <String>[];
    final args = <dynamic>[];
    if (idCongTrinh != null) {
      where.add(
        'nvct.${NhanVienCongTrinhTable.idCongTrinh} = ?',
      );
      args.add(idCongTrinh);
    }
    if (idNhanVienCongTrinh != null) {
      where.add(
        'nvct.${NhanVienCongTrinhTable.id} = ?',
      );
      args.add(idNhanVienCongTrinh);
    }

    final joinUlWhere = <String>[];
    if (tuNgay != null) {
      joinUlWhere.add(
        'date(ul.${UngLuongTable.ngayUng}) >= date(?)',
      );
      args.add(_formatDate(tuNgay));
    }
    if (denNgay != null) {
      joinUlWhere.add(
        'date(ul.${UngLuongTable.ngayUng}) <= date(?)',
      );
      args.add(_formatDate(denNgay));
    }
    if (thang != null) {
      joinUlWhere.add(
        'strftime("%m", ul.${UngLuongTable.ngayUng}) = ?',
      );
      args.add(thang.toString().padLeft(2, '0'));
    }
    if (nam != null) {
      joinUlWhere.add(
        'strftime("%Y", ul.${UngLuongTable.ngayUng}) = ?',
      );
      args.add(nam.toString());
    }
    if (kyLuong != null) {
      joinUlWhere.add(
        "strftime('%Y-%m', ul.${UngLuongTable.ngayUng}) = ?",
      );
      args.add(kyLuong);
    }
    if (!includeDeleted) {
      joinUlWhere.add(
        '(ul.${UngLuongTable.is_deleted} = 0)',
      );
    }
    final ulCondition = joinUlWhere.isEmpty
        ? ''
        : ' AND ${joinUlWhere.join(' AND ')}';
    final whereSql = where.isEmpty
        ? ''
        : 'WHERE ${where.join(' AND ')}';
    final rows = await db.rawQuery(
      '''
    SELECT
      nvct.id AS ${UngLuongDataColumns.idNhanVienCongTrinh},
      nvct.${NhanVienCongTrinhTable.idCongTrinh}
        AS ${UngLuongDataColumns.idCongTrinh},
      nv.${NhanVienTable.id}
        AS ${UngLuongDataColumns.nhanVienId},
      nv.${NhanVienTable.hoTen}
        AS ${UngLuongDataColumns.hoTen},
      ul.id
        AS ${UngLuongDataColumns.idUngLuong},
      ul.${UngLuongTable.soTien}
        AS ${UngLuongDataColumns.soTien},
      ul.${UngLuongTable.ngayUng}
        AS ${UngLuongDataColumns.ngayUng},
      ul.${UngLuongTable.lyDo}
        AS ${UngLuongDataColumns.lyDo},
      ul.${UngLuongTable.is_deleted}
        AS ${UngLuongDataColumns.isDeleted}
    FROM ${NhanVienCongTrinhTable.tableName} nvct
    LEFT JOIN ${NhanVienTable.tableName} nv
      ON nvct.${NhanVienCongTrinhTable.idNhanVien}
        = nv.${NhanVienTable.id}

    LEFT JOIN ${UngLuongTable.tableName} ul
      ON ul.${UngLuongTable.idNhanVienCongTrinh}
        = nvct.${NhanVienCongTrinhTable.id}
      $ulCondition
    $whereSql
    ORDER BY
      nv.${NhanVienTable.hoTen} ASC,
      date(ul.${UngLuongTable.ngayUng}) DESC
    ''',
      args,
    );
    return rows.map(UngLuongDataModel.fromMap).toList();
  }

//********************END DANH SÁCH*****************************
  // Thêm ứng lương
  Future<int> addUngLuong(Ungluong u) async {
    final db = await _dbHelper.database;
    return await db.insert(UngLuongTable.tableName, u.toMap());
  }
  Future<bool> isDoiUngTruLuong(int idUngLuong) async {
    final db = await _dbHelper.database;
    // Kiểm tra khoản ứng có được đối trừ chưa
    final ungLuong = await db.query(
      UngLuongTable.tableName,
      columns: [UngLuongTable.id],
      where: '''
                      ${UngLuongTable.id} = ?
                      AND ${UngLuongTable.soTienDaTru} > 0
                    ''',
      whereArgs: [idUngLuong],
      limit: 1,
    );
    final doiTru = await db.query(
      ChiTietDoiTruUngLuongTable.tableName,
      columns: [UngLuongTable.id],
      where: '''
                      ${ChiTietDoiTruUngLuongTable.idUngLuong} = ?
                    ''',
      whereArgs: [idUngLuong],
      limit: 1,
    );
    if(ungLuong.isNotEmpty || doiTru.isNotEmpty){
      return true;
    }
    return false;
  }
  // Sửa ứng lương
  Future<int> updateUngLuong(Ungluong u) async {
    final db = await _dbHelper.database;
    // Kiểm tra khoản ứng có được đối trừ chưa
    bool isDoiUngTruLuong = await this.isDoiUngTruLuong(u.id!);
    if (isDoiUngTruLuong) {
      throw Exception(
        'Khoản ứng đã được đối trừ, không thể sửa',
      );
    }
    return await db.update(
      UngLuongTable.tableName,
      u.toMap(),
      where: '${UngLuongTable.id} = ?',
      whereArgs: [u.id],
    );
  }

  // Xóa ứng lương
  Future<int> deleteUngLuong(int id) async {
    final db = await _dbHelper.database;
    final results = await Future.wait([
      db.query(
        ChiTietDoiTruUngLuongTable.tableName,
        columns: [ChiTietDoiTruUngLuongTable.idUngLuong],
        where: '${ChiTietDoiTruUngLuongTable.idUngLuong} = ?',
        whereArgs: [id],
        limit: 1,
      ),
    ]);
    if (results[0].isNotEmpty) {
      throw Exception('Khoản ứng đã được đối trừ, không thể xóa');
    }
    try{
      return await db.delete(
        UngLuongTable.tableName,
        where: '${UngLuongTable.id} = ?',
        whereArgs: [id],
      );
    }catch(e){
      throw Exception('Lỗi không thể xóa:');
    }
  }

  //************* ỨNG LƯƠNG TỪNG NHÂN VIÊN **************

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
