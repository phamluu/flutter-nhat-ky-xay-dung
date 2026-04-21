import '../db_helper.dart';
import '../models/CongTrinh.dart';

class CongtrinhReponsitory {
  final _dbHelper = DBHelper.instance;
  Future<List<CongTrinh>> getDanhSachCongTrinh() async {
    final db = await _dbHelper.database;
    final maps = await db.query('cong_trinh', orderBy: 'datetime(ngay_tao) DESC',);
    return maps.map((map) => CongTrinh.fromMap(map)).toList();
  }
  Future<CongTrinh?> getCongTrinh(idCongTrinh) async{
    final db = await _dbHelper.database;
    final maps = await db.query('cong_trinh',where: 'id = ?',
        whereArgs: [idCongTrinh], orderBy: 'ngay_bat_dau DESC');
    if (maps.isNotEmpty) {
      return CongTrinh.fromMap(maps.first);
    } else {
      return null;
    }
  }
  Future<List<CongTrinh>> getCongTrinhWithTienDo() async {
    final db = await DBHelper.instance.database;
    final maps = await db.rawQuery('''
    SELECT 
      ct.*,
      (
        SELECT 
          CASE 
            WHEN SUM(trong_so) = 0 THEN 0
            ELSE SUM(phan_tram_thuc_te * trong_so) / SUM(trong_so)
          END
        FROM tien_do_cong_trinh td
        WHERE td.id_cong_trinh = ct.id
      ) as tienDo
    FROM cong_trinh ct
  ''');
    return maps.map((map) => CongTrinh.fromMap(map)).toList();
  }
}