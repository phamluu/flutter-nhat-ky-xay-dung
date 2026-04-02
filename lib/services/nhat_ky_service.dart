import 'package:sqflite/sqflite.dart';
import '../data/db_helper.dart';
import '../data/models/CongTrinh.dart';
import '../data/models/NhatKy.dart';

class NhatKyService {
  final _dbHelper = DBHelper.instance;
  Future<int> insertNhatKy(NhatKy nk) async {
    final db = await _dbHelper.database;
    return await db.insert('nhat_ky', nk.toMap());
  }

  // -----Nhật ký ---------
  Future<List<NhatKyViewModel>> getAllNhatKy([int? idCongTrinh]) async {
    final db = await _dbHelper.database;

    // 1. Lấy tất cả công trình
    final congTrinhMaps = await db.query('cong_trinh');
    final congTrinhList = congTrinhMaps.map((e) => CongTrinh.fromMap(e)).toList();
    final congTrinhMap = {for (var c in congTrinhList) c.id: c};

    // 2. Lấy nhật ký (có lọc theo công trình nếu truyền vào)
    List<Map<String, dynamic>> maps;
    if (idCongTrinh != null) {
      maps = await db.query(
        'nhat_ky',
        where: 'id_cong_trinh = ?',
        whereArgs: [idCongTrinh],
        orderBy: 'ngay_tao DESC',
      );
    } else {
      maps = await db.query(
        'nhat_ky',
        orderBy: 'ngay_tao DESC',
      );
    }
    // 3. Map sang ViewModel (có query đếm công nhân)
    List<NhatKyViewModel> result = [];
    for (final e in maps) {
      final ct = congTrinhMap[e['id_cong_trinh']];
      final nhatKy = NhatKy.fromMap(e, congTrinh: ct);

      if (nhatKy.ngayTrienKhai == null) {
        result.add(NhatKyViewModel(nhatKy: nhatKy, soLuongCongNhan: 0));
        continue;
      }

      final countRes = await db.rawQuery(
        '''
    SELECT COUNT(DISTINCT nvct.id) AS cnt
    FROM cham_cong cnt
    JOIN nhan_vien_cong_trinh nvct
      ON cnt.id_nhan_vien_cong_trinh = nvct.id
    WHERE cnt.ngay = ? AND nvct.idCongTrinh = ?
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


  Future<int> updateNhatKy(NhatKy nk) async {
    final db = await _dbHelper.database;
    return await db.update(
      'nhat_ky',
      nk.toMap(),
      where: 'id = ?',
      whereArgs: [nk.id],
    );
  }

  Future<int> deleteNhatKy(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'nhat_ky',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ----- Hình ảnh -------
  Future<void> insertImages(int nhatKyId, List<String> paths) async {
    final db = await DBHelper.instance.database;

    for (var path in paths) {
      await db.insert('nhat_ky_hinh_anh', {
        'id_nhat_ky': nhatKyId,
        'url': path,
      });
    }
  }

  Future<List<String>> getImages(int nhatKyId) async {
    final db = await DBHelper.instance.database;

    final result = await db.query(
      'nhat_ky_hinh_anh',
      where: 'id_nhat_ky = ?',
      whereArgs: [nhatKyId],
    );

    return result.map((e) => e['url'] as String).toList();
  }

  Future<void> deleteImages(int nhatKyId) async {
    final db = await DBHelper.instance.database;

    await db.delete(
      'nhat_ky_hinh_anh',
      where: 'id_nhat_ky = ?',
      whereArgs: [nhatKyId],
    );
  }
}
