import '../data/db_helper.dart';
import '../data/models/CongTrinh.dart';

class CongTrinhService {
  final _dbHelper = DBHelper.instance;

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
  Future<List<CongTrinh>> getDanhSachCongTrinh() async {
    final db = await _dbHelper.database;
    final maps = await db.query('cong_trinh', orderBy: 'ngay_bat_dau DESC');
    return maps.map((map) => CongTrinh.fromMap(map)).toList();
  }

  Future<int> themCongTrinh(CongTrinh congTrinh) async {
    final db = await _dbHelper.database;
    return await db.insert('cong_trinh', congTrinh.toMap());
  }
  Future<void> updateCongTrinh(CongTrinh ct) async {
    final db = await _dbHelper.database;
    await db.update(
      'cong_trinh',
      ct.toMap(),
      where: 'id = ?',
      whereArgs: [ct.id],
    );
  }
  Future<int> deleteCongTrinh(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'cong_trinh',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


}
