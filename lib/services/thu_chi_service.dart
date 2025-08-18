import 'package:nhat_ky_xay_dung/services/cong_trinh_service.dart';
import 'package:nhat_ky_xay_dung/services/danh_muc_thu_chi_service.dart';
import 'package:sqflite/sqflite.dart';

import '../data/db_helper.dart';
import '../data/models/CongTrinh.dart';
import '../data/models/DanhMucThuChi.dart';
import '../data/models/ThuChi.dart';

class ThuChiService {
  final _dbHelper = DBHelper.instance;
  Future<int> insert(ThuChi tc) async {
    final db = await _dbHelper.database;
    return await db.insert('thu_chi', tc.toMap());
  }

  Future<List<ThuChi>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('thu_chi', orderBy: 'ngay DESC');
    return maps.map((e) => ThuChi.fromMap(e)).toList();
  }

  Future<List<ThuChi>> getAllWithDetails() async {
    final db = await _dbHelper.database;
    final res = await db.rawQuery('''
        SELECT tc.*, ct.id as ct_id, ct.ten as ct_ten, dm.id as dm_id, dm.ten as dm_ten
        FROM thu_chi tc
        LEFT JOIN cong_trinh ct ON tc.id_cong_trinh = ct.id
        LEFT JOIN danh_muc_thu_chi dm ON tc.id_danh_muc_thu_chi = dm.id
        ORDER BY tc.ngay DESC
      ''');
    return res.map((row) {
      final congTrinh = row['ct_id'] != null
          ? CongTrinh(id: row['ct_id'] as int, ten: row['ct_ten'] as String)
          : null;

      final danhMuc = row['dm_id'] != null
          ? DanhMucThuChi(id: row['dm_id'] as int, ten: row['dm_ten'] as String)
          : null;
      return ThuChi.fromMap(row, congTrinh: congTrinh, danhMucThuChi: danhMuc);
    }).toList();
  }

  // final _thuChiRepo = ThuChiRepository();
   final _danhMucRepo = DanhMucThuChiService();
   final _congTrinhRepo = CongTrinhService();

  Future<ThuChiViewModel> loadThuChiViewModel() async {
    final allThuChis = await getAllWithDetails();
    final danhMucs = await _danhMucRepo.getAll();
    final congTrinhs = await _congTrinhRepo.getDanhSachCongTrinh();

    // --- Thu chi công ty ---
    final thuChiCongTyList = allThuChis.where((tc) => tc.idCongTrinh == null).toList();

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
        var existing = congTyDanhMucs.where((e) => e.danhMucThuChi?.id == dm.id).toList();
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
      final thuChiCtList = allThuChis.where((tc) => tc.idCongTrinh == ct.id).toList();

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
          var existing = ctDanhMucs.where((e) => e.danhMucThuChi?.id == dm.id).toList();
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

  Future<int> update(ThuChi tc) async {
    final db = await _dbHelper.database;
    return await db.update(
      'thu_chi',
      tc.toMap(),
      where: 'id = ?',
      whereArgs: [tc.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('thu_chi', where: 'id = ?', whereArgs: [id]);
  }
  Future<int> countByDanhMuc(int idDanhMuc) async {
    final db = await _dbHelper.database;
    final res = await db.rawQuery(
      'SELECT COUNT(*) as c FROM thu_chi WHERE id_danh_muc_thu_chi = ?',
      [idDanhMuc],
    );
    return (res.first['c'] as int?) ?? 0;
  }

}
