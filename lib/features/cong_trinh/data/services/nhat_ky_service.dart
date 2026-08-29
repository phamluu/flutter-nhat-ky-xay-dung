import 'package:nhat_ky_xay_dung/data/tables/cham_cong_chi_tiet_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhat_ky_table.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../data/db_helper.dart';
import '../../../../data/tables/nhat_ky_hinh_anh_table.dart';
import '../models/CongTrinh.dart';
import '../models/NhatKyCongTrinh.dart';

class NhatKyService {
  final _dbHelper = DBHelper.instance;
  Future<int> insertNhatKy(NhatKyCongTrinh nk) async {
    final db = await _dbHelper.database;
    return await db.insert(NhatKyTable.tableName, nk.toMap());
  }

  // -----Nhật ký ---------
  Future<List<NhatKyViewModel>> getAllNhatKy([int? idCongTrinh]) async {
    final db = await _dbHelper.database;

    // 1. Lấy tất cả công trình
    final congTrinhMaps = await db.query(CongTrinhTable.tableName);
    final congTrinhList = congTrinhMaps.map((e) => CongTrinh.fromMap(e)).toList();
    final congTrinhMap = {for (var c in congTrinhList) c.id: c};

    // 2. Lấy nhật ký (có lọc theo công trình nếu truyền vào)
    List<Map<String, dynamic>> maps;
    if (idCongTrinh != null) {
      maps = await db.query(
        NhatKyTable.tableName,
        where: '${NhatKyTable.idCongTrinh} = ?',
        whereArgs: [idCongTrinh],
        orderBy: '${NhatKyTable.ngayTao} DESC',
      );
    } else {
      maps = await db.query(
        NhatKyTable.tableName,
        orderBy: '${NhatKyTable.ngayTao} DESC',
      );
    }
    // 3. Map sang ViewModel (có query đếm công nhân)
    List<NhatKyViewModel> result = [];
    for (final e in maps) {
      final ct = congTrinhMap[e[NhatKyTable.idCongTrinh]];
      final nhatKy = NhatKyCongTrinh.fromMap(e, congTrinh: ct);

      if (nhatKy.ngayTrienKhai == null) {
        result.add(NhatKyViewModel(nhatKy: nhatKy, soLuongCongNhan: 0));
        continue;
      }

      final countRes = await db.rawQuery(
        '''
    SELECT COUNT(DISTINCT nvct.id) AS cnt
    FROM ${ChamCongChiTietTable.tableName} cnt
    JOIN ${NhanVienCongTrinhTable.tableName} nvct
      ON cnt.${ChamCongChiTietTable.idNhanVienCongTrinh} = nvct.${NhanVienCongTrinhTable.id}
    WHERE cnt.${ChamCongChiTietTable.ngay} = ? AND nvct.${NhanVienCongTrinhTable.idCongTrinh} = ?
    ''',
        [nhatKy.ngayTrienKhai, nhatKy.idCongTrinh],
      );

      final soLuongCongNhan = Sqflite.firstIntValue(countRes) ?? 0;

      result.add(NhatKyViewModel(
        nhatKy: nhatKy,
        soLuongCongNhan: soLuongCongNhan,
      ));
    }
    return result;
  }


  Future<int> updateNhatKy(NhatKyCongTrinh nk) async {
    final db = await _dbHelper.database;
    return await db.update(
      NhatKyTable.tableName,
      nk.toMap(),
      where: '${NhatKyHinhAnhTable.id} = ?',
      whereArgs: [nk.id],
    );
  }

  Future<int> deleteNhatKy(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      NhatKyTable.tableName,
      where: '${NhatKyHinhAnhTable.id} = ?',
      whereArgs: [id],
    );
  }

  // ----- Hình ảnh -------
  Future<void> insertImages(int nhatKyId, List<String> paths) async {
    final db = await DBHelper.instance.database;

    for (var path in paths) {
      await db.insert(NhatKyHinhAnhTable.tableName, {
        NhatKyHinhAnhTable.idNhatKy: nhatKyId,
        NhatKyHinhAnhTable.url: path,
      });
    }
  }

  Future<List<String>> getImages(int nhatKyId) async {
    final db = await DBHelper.instance.database;

    final result = await db.query(
      NhatKyHinhAnhTable.tableName,
      where: '${NhatKyHinhAnhTable.idNhatKy} = ?',
      whereArgs: [nhatKyId],
    );

    return result.map((e) => e['${NhatKyHinhAnhTable.url}'] as String).toList();
  }

  Future<void> deleteImages(int nhatKyId) async {
    final db = await DBHelper.instance.database;

    await db.delete(
      NhatKyHinhAnhTable.tableName,
      where: '${NhatKyHinhAnhTable.idNhatKy} = ?',
      whereArgs: [nhatKyId],
    );
  }
}
