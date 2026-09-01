import 'package:nhat_ky_xay_dung/data/tables/cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/danh_muc_thu_chi_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/thu_chi_table.dart';

import '../../../../data/db_helper.dart';
import '../../../cong_trinh/data/models/CongTrinh.dart';
import '../../../luong/data/repositories/ChiLuongRepository.dart';
import '../../../luong/data/repositories/ung_luong_repository.dart';
import '../models/DanhMucThuChi.dart';
import '../models/ThuChi.dart';
import '../../../cong_trinh/data/respositories/CongTrinhReponsitory.dart';
import 'package:intl/intl.dart';

import 'danh_muc_thu_chi_service.dart';

class ThuChiService {
  final _dbHelper = DBHelper.instance;
  final _danhMucRepo = DanhMucThuChiService();
  final _congTrinhRepo = CongtrinhReponsitory();
  final _tamUng = UngLuongRepository();
  final _chiLuong = ChiLuongRepository();

  /**************** ***************/

  Future<int> insert(ThuChi tc) async {
    final db = await _dbHelper.database;
    return await db.insert(ThuChiTable.tableName, tc.toMap());
  }
  Future<void> insertAll(List<ThuChi> list) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (var item in list) {
        batch.insert(ThuChiTable.tableName, item.toMap());
      }
      await batch.commit(noResult: true);
    });
  }
  Future<int> update(ThuChi tc) async {
    final db = await _dbHelper.database;
    return await db.update(
      ThuChiTable.tableName,
      tc.toMap(),
      where: '${ThuChiTable.id} = ?',
      whereArgs: [tc.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(ThuChiTable.tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ThuChi>> getAllWithDetails([int? idCongTrinh, DateTime? tuNgay, DateTime? denNgay,]) async {
    final db = await _dbHelper.database;
    final conditions = <String>[];
    final args = <dynamic>[];
    if (idCongTrinh != null) {
      conditions.add('tc.${ThuChiTable.id_cong_trinh} = ?');
      args.add(idCongTrinh);
    }
    // Lọc từ ngày
    if (tuNgay != null) {
      conditions.add('date(tc.${ThuChiTable.ngay}) >= date(?)');
      args.add(
        DateFormat('yyyy-MM-dd').format(tuNgay),
      );
    }
    // Lọc đến ngày
    if (denNgay != null) {
      conditions.add('date(tc.ngay) <= date(?)');
      args.add(
        DateFormat('yyyy-MM-dd').format(denNgay),
      );
    }
    final whereClause =
        conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : '';
    final res = await db.rawQuery(
      '''
    SELECT 
      tc.*, 
      ct.id as ct_id, 
      ct.ten as ct_ten, 
      dm.id as dm_id, 
      dm.ten as dm_ten
    FROM ${ThuChiTable.tableName} tc
    LEFT JOIN ${CongTrinhTable.tableName} ct 
      ON tc.${ThuChiTable.id_cong_trinh} = ct.id
    LEFT JOIN ${DanhMucThuChiTable.tableName} dm 
      ON tc.${ThuChiTable.id_danh_muc_thu_chi} = dm.id
    $whereClause
    ORDER BY tc.${ThuChiTable.ngay} DESC
    ''',
      args,
    );
    return res.map((row) {
      final congTrinh = row['ct_id'] != null
          ? CongTrinh(
              id: row['ct_id'] as int,
              ten: row['ct_ten'] as String,
            )
          : null;
      final danhMuc = row['dm_id'] != null
          ? DanhMucThuChi(
              id: row['dm_id'] as int,
              ten: row['dm_ten'] as String,
            )
          : null;
      return ThuChi.fromMap(
        row,
        congTrinh: congTrinh,
        danhMucThuChi: danhMuc,
      );
    }).toList();
  }

  Future<ThuChiViewModel> loadThuChiViewModel([int? idCongTrinh]) async {
    final allThuChis = await getAllWithDetails(idCongTrinh);
    final danhMucs = await _danhMucRepo.getAll();
    final congTrinhs = await _congTrinhRepo.getDanhSachCongTrinh();
    // --- Thu chi công ty ---
    final thuChiCongTyList =
        allThuChis.where((tc) => tc.idCongTrinh == null).toList();
    final List<ThuChiDanhMucViewModel> congTyDanhMucs = [];
    final List<ThuChi> congTyKhac = [];
    for (var tc in thuChiCongTyList) {
      final dm = danhMucs.firstWhere(
        (d) => d.id == tc.idDanhMucThuChi,
        orElse: () => DanhMucThuChi(id: 0, ten: "Khác"),
      );
      if (dm.id == 0) {
        congTyKhac.add(tc);
      } else {
        var existing =
            congTyDanhMucs.where((e) => e.danhMucThuChi?.id == dm.id).toList();
        if (existing.isNotEmpty) {
          existing.first.thuchis?.add(tc);
        } else {
          congTyDanhMucs.add(ThuChiDanhMucViewModel()
            ..danhMucThuChi = dm
            ..thuchis = [tc]);
        }
      }
    }

    final congTyVM = ThuChiCongTyViewModel()
      ..thuChiDanhMucs = congTyDanhMucs
      ..thuChiKhacs = (ThuChiKhacViewModel()..thuchis = congTyKhac);

    // --- Thu chi theo công trình ---
    final List<ThuChiCongTrinhViewModel> congTrinhVMs = [];

    for (var ct in congTrinhs) {
      final thuChiCtList =
          allThuChis.where((tc) => tc.idCongTrinh == ct.id).toList();

      final List<ThuChiDanhMucViewModel> ctDanhMucs = [];
      final List<ThuChi> ctKhac = [];

      for (var tc in thuChiCtList) {
        final dm = danhMucs.firstWhere(
          (d) => d.id == tc.idDanhMucThuChi,
          orElse: () => DanhMucThuChi(id: 0, ten: "Khác"),
        );

        if (dm.id == 0) {
          ctKhac.add(tc);
        } else {
          var existing =
              ctDanhMucs.where((e) => e.danhMucThuChi?.id == dm.id).toList();
          if (existing.isNotEmpty) {
            existing.first.thuchis?.add(tc);
          } else {
            ctDanhMucs.add(ThuChiDanhMucViewModel()
              ..danhMucThuChi = dm
              ..thuchis = [tc]);
          }
        }
      }

      congTrinhVMs.add(ThuChiCongTrinhViewModel()
        ..congTrinh = ct
        ..thuChiDanhMucs = ctDanhMucs
        ..thuChiKhacs = (ThuChiKhacViewModel()..thuchis = ctKhac));
    }

    return ThuChiViewModel()
      ..thuChiCongTy = congTyVM
      ..thuChiCongTrinhs = congTrinhVMs;
  }

  Future<ThuChiCongTrinhViewModel> loadThuChiCongTrinh(int? idCongTrinh,{DateTime? tuNgay, DateTime? denNgay}) async {
    final allThuChis = await getAllWithDetails(idCongTrinh, tuNgay, denNgay);
    final danhMucs = await _danhMucRepo.getAll();
    final congTrinh = await _congTrinhRepo.getCongTrinh(idCongTrinh);
    final thuChiCtList =
        allThuChis.where((tc) => tc.idCongTrinh == idCongTrinh).toList();

    final List<ThuChiDanhMucViewModel> ctDanhMucs = [];
    final List<ThuChi> ctKhac = [];

    ////// Tính lương ///////////
    final List<Map<String, dynamic>> tamUng = await _tamUng.getUngLuong(
        idCongTrinh: idCongTrinh!, tuNgay: tuNgay, denNgay: denNgay);
    final List<Map<String, dynamic>> chiLuong = await _chiLuong.getChiLuong(
        idCongTrinh: idCongTrinh!, tuNgay: tuNgay, denNgay: denNgay);
    for (var tc in thuChiCtList) {
      final dm = danhMucs.firstWhere(
        (d) => d.id == tc.idDanhMucThuChi,
        orElse: () => DanhMucThuChi(id: 0, ten: "Khác"),
      );

      if (dm.id == 0) {
        ctKhac.add(tc);
      } else {
        var existing =
            ctDanhMucs.where((e) => e.danhMucThuChi?.id == dm.id).toList();
        if (existing.isNotEmpty) {
          existing.first.thuchis?.add(tc);
        } else {
          ctDanhMucs.add(ThuChiDanhMucViewModel()
            ..danhMucThuChi = dm
            ..thuchis = [tc]);
        }
      }
    }

    return ThuChiCongTrinhViewModel()
      ..congTrinh = congTrinh!
      ..thuChiDanhMucs = ctDanhMucs
      ..thuChiKhacs = (ThuChiKhacViewModel()..thuchis = ctKhac)
      ..tamUngLuong = tamUng.fold<double>(
        0,
        (sum, item) => sum + (item['soTien'] as num? ?? 0).toDouble(),
      )
      ..daChiLuong = chiLuong.fold<double>(
        0,
            (sum, item) => sum + (item['soTien'] as num? ?? 0).toDouble(),
      );
  }

  Future<int> countByDanhMuc(int idDanhMuc) async {
    final db = await _dbHelper.database;
    final res = await db.rawQuery(
      'SELECT COUNT(*) as c FROM ${ThuChiTable.tableName} WHERE ${ThuChiTable.id_danh_muc_thu_chi} = ?',
      [idDanhMuc],
    );
    return (res.first['c'] as int?) ?? 0;
  }

  Future<(DateTime?, DateTime?)> getThuChiDateRange(int? idCongTrinh) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
    SELECT 
      MIN(${ThuChiTable.ngay}) AS min_date, 
      MAX(${ThuChiTable.ngay}) AS max_date 
    FROM ${ThuChiTable.tableName}
    WHERE ${ThuChiTable.id_cong_trinh} = ?
  ''', [idCongTrinh]);
    if (result.isNotEmpty) {
      // Ép kiểu về String? trước
      final minStr = result.first['min_date'] as String?;
      final maxStr = result.first['max_date'] as String?;

      // Parse từ String sang DateTime
      final first = minStr != null ? DateTime.tryParse(minStr) : null;
      final last = maxStr != null ? DateTime.tryParse(maxStr) : null;
      return (first, last);
    }
    return (null, null);
  }
}
