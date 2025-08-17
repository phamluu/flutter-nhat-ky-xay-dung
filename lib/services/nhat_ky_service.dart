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

  Future<List<NhatKy>> getAllNhatKy([int? idCongTrinh]) async {
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

    // 3. Map idCongTrinh sang CongTrinh
    return maps.map((e) {
      final ct = congTrinhMap[e['id_cong_trinh']];
      return NhatKy.fromMap(e, congTrinh: ct);
    }).toList();
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
}
