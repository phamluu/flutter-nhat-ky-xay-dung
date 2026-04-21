import '../data/db_helper.dart';
import '../data/models/CongTrinh.dart';
import '../data/repositories/CongTrinhReponsitory.dart';
import '../data/repositories/TienDoRepository.dart';

class CongTrinhService {
  final _dbHelper = DBHelper.instance;
  final CongtrinhReponsitory repo;

  CongTrinhService({
    required this.repo
  });
  Future<CongTrinh?> getCongTrinh(idCongTrinh) async{
    return repo.getCongTrinh(idCongTrinh);
  }
  Future<List<CongTrinh>> getDanhSachCongTrinh() async {
    return repo.getDanhSachCongTrinh();
  }
  Future<List<CongTrinh>> getCongTrinhWithTienDo() async {
    return repo.getCongTrinhWithTienDo();
  }
  Future<int> themCongTrinh(CongTrinh congTrinh) async {
    final db = await _dbHelper.database;
    return await db.insert('cong_trinh', congTrinh.toMapInsert());
  }
  Future<void> updateCongTrinh(CongTrinh ct) async {
    final db = await _dbHelper.database;
    await db.update(
      'cong_trinh',
      ct.toMapUpdate(),
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
