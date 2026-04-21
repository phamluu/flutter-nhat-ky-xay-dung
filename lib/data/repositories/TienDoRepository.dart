import '../db_helper.dart';
import '../models/TienDoCongTrinhModel.dart';

class TienDoRepository {
  final dbHelper = DBHelper.instance;

  Future<int> insert(TienDoCongTrinhModel model) async {
    final db = await dbHelper.database;
    return await db.insert('tien_do_cong_trinh', model.toMap());
  }

  Future<List<TienDoCongTrinhModel>> getByCongTrinh(int idCongTrinh) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'tien_do_cong_trinh',
      where: 'id_cong_trinh = ?',
      whereArgs: [idCongTrinh],
      orderBy: 'ngay_bat_dau ASC',
    );

    return result.map((e) => TienDoCongTrinhModel.fromMap(e)).toList();
  }

  Future<int> update(TienDoCongTrinhModel model) async {
    final db = await dbHelper.database;
    return await db.update(
      'tien_do_cong_trinh',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'tien_do_cong_trinh',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> tinhTienDoCongTrinh(int idCongTrinh) async {
    final db = await DBHelper.instance.database;
    final result = await db.rawQuery('''
    SELECT 
      SUM(phan_tram_thuc_te * trong_so) / SUM(trong_so) as tienDo
    FROM tien_do_cong_trinh
    WHERE id_cong_trinh = ?
  ''', [idCongTrinh]);
    return (result.first['tienDo'] as num?)?.toDouble() ?? 0;
  }
}