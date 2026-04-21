import '../db_helper.dart';
import '../models/ChiLuong.dart';

class ChiLuongRepository {
  final _dbHelper = DBHelper.instance;
  Future<int> insert(ChiLuongModel model) async {
    final db = await _dbHelper.database;
    return await db.insert('chi_luong', model.toMap());
  }

  Future<List<ChiLuongModel>> getByBangLuong(int idBangLuong) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'chi_luong',
      where: 'idBangLuong = ?',
      whereArgs: [idBangLuong],
      orderBy: 'ngayChi DESC',
    );
    return result.map((e) => ChiLuongModel.fromMap(e)).toList();
  }
  Future<List<ChiLuongModel>> getByCongTrinhThangNamWithNhanVien(
      int idCongTrinh, int thang, int nam) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
    SELECT 
      cl.*,
      nv.ho_ten AS tenNhanVien
    FROM chi_luong cl
    INNER JOIN bang_luong bl ON cl.idBangLuong = bl.id
    INNER JOIN nhan_vien_cong_trinh nvct 
        ON bl.idNhanVienCongTrinh = nvct.id
    INNER JOIN nhan_vien nv 
        ON nvct.idNhanVien = nv.id
    WHERE nvct.idCongTrinh = ?
      AND bl.thang = ?
      AND bl.nam = ?
    ORDER BY cl.ngayChi DESC
  ''', [idCongTrinh, thang, nam]);
    return result.map((e) => ChiLuongModel.fromMap(e)).toList();
  }
  Future<double> getTongDaChi(int idBangLuong) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(soTien) as total FROM chi_luong WHERE idBangLuong = ?',
      [idBangLuong],
    );
    final value = result.first['total'];
    return (value as num?)?.toDouble() ?? 0;
  }
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'chi_luong',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}