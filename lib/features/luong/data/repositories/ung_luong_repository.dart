import 'package:nhat_ky_xay_dung/data/tables/cham_cong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_table.dart';
import 'package:nhat_ky_xay_dung/features/luong/data/models/UngLuongDataModel.dart';
import 'package:path/path.dart';
import '../../../../data/db_helper.dart';
import '../../../../data/tables/chi_tiet_doi_tru_ung_luong.dart';
import '../../../../data/tables/ung_luong_table.dart';
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

  Future<double> tongTienUngLuongForNhanVien({required int idNhanVienCongTrinh,LoaiTongUngLuong loai = LoaiTongUngLuong.tatCa,}) async {
      final db = await _dbHelper.database;
      String condition = '';
      switch (loai) {
          case LoaiTongUngLuong.tatCa:
          condition = '';
          case LoaiTongUngLuong.chuaDoiTru:
          condition = '''
                AND (
                  COALESCE(ul.${UngLuongTable.soTien}, 0)
                  -
                  COALESCE((
                    SELECT SUM(ct.${ChiTietDoiTruUngLuongTable.soTienDoiTru})
                    FROM ${ChiTietDoiTruUngLuongTable.tableName} ct
                    WHERE ct.${ChiTietDoiTruUngLuongTable.idUngLuong}
                          = ul.${UngLuongTable.id}
                      AND COALESCE(
                        ct.${ChiTietDoiTruUngLuongTable.isDeleted},
                        0
                      ) = 0
                  ), 0)
                ) > 0
              ''';
          case LoaiTongUngLuong.daDoiTru:
          condition = '''
                AND COALESCE((
                  SELECT SUM(ct.${ChiTietDoiTruUngLuongTable.soTienDoiTru})
                  FROM ${ChiTietDoiTruUngLuongTable.tableName} ct
                  WHERE ct.${ChiTietDoiTruUngLuongTable.idUngLuong}
                        = ul.${UngLuongTable.id}
                    AND COALESCE(
                      ct.${ChiTietDoiTruUngLuongTable.isDeleted},
                      0
                    ) = 0
                ), 0) > 0
              ''';
          }
      final results = await db.rawQuery(
      '''
        SELECT
          COALESCE(
            SUM(
              CASE
                WHEN ? = 0 THEN
                  COALESCE(ul.${UngLuongTable.soTien}, 0)
                WHEN ? = 1 THEN
                  MAX(
                    COALESCE(ul.${UngLuongTable.soTien}, 0)
                    -
                    COALESCE((
                      SELECT SUM(
                        ct.${ChiTietDoiTruUngLuongTable.soTienDoiTru}
                      )
                      FROM ${ChiTietDoiTruUngLuongTable.tableName} ct
                      WHERE ct.${ChiTietDoiTruUngLuongTable.idUngLuong}
                            = ul.${UngLuongTable.id}
                        AND COALESCE(
                          ct.${ChiTietDoiTruUngLuongTable.isDeleted},
                          0
                        ) = 0
                    ), 0),
                    0
                  )
                ELSE
                  COALESCE((
                    SELECT SUM(
                      ct.${ChiTietDoiTruUngLuongTable.soTienDoiTru}
                    )
                    FROM ${ChiTietDoiTruUngLuongTable.tableName} ct
                    WHERE ct.${ChiTietDoiTruUngLuongTable.idUngLuong}
                          = ul.${UngLuongTable.id}
                      AND COALESCE(
                        ct.${ChiTietDoiTruUngLuongTable.isDeleted},
                        0
                      ) = 0
                  ), 0)
              END
            ),
            0
          ) AS tongTien
        FROM ${UngLuongTable.tableName} ul
        WHERE ul.${UngLuongTable.idNhanVienCongTrinh} = ?
          AND COALESCE(
            ul.${UngLuongTable.is_deleted},
            0
          ) = 0
          $condition
        ''',
        [
            loai == LoaiTongUngLuong.tatCa
            ? 0
                : loai == LoaiTongUngLuong.chuaDoiTru
            ? 1
                : 2,
            loai == LoaiTongUngLuong.tatCa
            ? 0
                : loai == LoaiTongUngLuong.chuaDoiTru
            ? 1
                : 2,
            idNhanVienCongTrinh,
        ],
      );
      if (results.isEmpty) {
      return 0;
      }
      return (results.first['tongTien'] as num?)?.toDouble() ?? 0;
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
            ngayUng: row['ngayUng'] != null
                ? DateTime.tryParse(
              row['ngayUng'].toString(),
            )
                : null,
            lyDo: row['lyDo']?.toString(),
          ),
        );
      }
    }

    return map.values.toList();
  }
  // Danh sách ứng lương của 1 nhân viên
  Future<List<Ungluong>> getUngLuongNhanVien(int idNhanVienCongTrinh, { String? kyLuong,int? thang,int? nam,
      }) async {
    final db = await _dbHelper.database;
    final where = <String>[
      '${UngLuongTable.idNhanVienCongTrinh} = ?',
    ];
    final whereArgs = <dynamic>[
      idNhanVienCongTrinh,
    ];
    if (kyLuong != null && kyLuong.isNotEmpty) {
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
    return result.map((e) => Ungluong.fromMap(e)).toList();
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

  // Sửa ứng lương
  Future<int> updateUngLuong(Ungluong u) async {
    final db = await _dbHelper.database;
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
    return await db.delete(
      UngLuongTable.tableName,
      where: '${UngLuongTable.id} = ?',
      whereArgs: [id],
    );
  }

  //************* ỨNG LƯƠNG TỪNG NHÂN VIÊN **************

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
