import 'package:sqflite/sqflite.dart';
import '../db_helper.dart';

class ChotChiLuongRepository {
  final _dbHelper = DBHelper.instance;

  /// 👉 insert hoặc update bảng lương (chốt)
  Future<int> upsertBangLuong({
    required int idNhanVienCongTrinh,
    required int thang,
    required int nam,
    required double tongCong,
    required double tongLuong,
    required double tongUng,
    required double thucNhan,
  }) async {
    final db = await _dbHelper.database;

    return await db.insert(
      'bang_luong',
      {
        'idNhanVienCongTrinh': idNhanVienCongTrinh,
        'thang': thang,
        'nam': nam,
        'tongCong': tongCong,
        'tongLuong': tongLuong,
        'tongUng': tongUng,
        'thucNhan': thucNhan,
        'ngayChot': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 👉 lấy bảng lương đã chốt
  Future<Map<String, dynamic>?> getBangLuong(
      int idNvct, int thang, int nam) async
  {
    final db = await _dbHelper.database;
    final result = await db.query(
      'bang_luong',
      where: 'idNhanVienCongTrinh = ? AND thang = ? AND nam = ?',
      whereArgs: [idNvct, thang, nam],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return result.first;
  }

  /// 👉 thêm chi lương
  Future<void> insertChiLuong({
    required int idBangLuong,
    required double soTien,
    String? ghiChu,
  }) async {
    final db = await _dbHelper.database;

    await db.insert('chi_luong', {
      'idBangLuong': idBangLuong,
      'soTien': soTien,
      'ngayChi': DateTime.now().toIso8601String(),
      'ghiChu': ghiChu,
    });
  }

  Future<Set<int>> getDanhSachDaChot(
      int idCongTrinh, int thang, int nam) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
    SELECT idNhanVienCongTrinh
    FROM bang_luong
    WHERE thang = ? AND nam = ?
  ''', [thang, nam]);

    return result
        .map((e) => (e['idNhanVienCongTrinh'] as num).toInt())
        .toSet();
  }
  /// 👉 tổng đã chi
  Future<double> getTongDaChi(int idBangLuong) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(soTien) as tong
      FROM chi_luong
      WHERE idBangLuong = ?
    ''', [idBangLuong]);

    return (result.first['tong'] as num?)?.toDouble() ?? 0;
  }

  Future<List<Map<String, dynamic>>> getBangLuongByCongTrinh(
      int idCongTrinh, int thang, int nam) async {

    final db = await _dbHelper.database;

    return await db.rawQuery('''
    SELECT bl.*, nvct.idCongTrinh
    FROM bang_luong bl
    INNER JOIN nhan_vien_cong_trinh nvct
      ON bl.idNhanVienCongTrinh = nvct.id
    WHERE nvct.idCongTrinh = ?
      AND bl.thang = ?
      AND bl.nam = ?
  ''', [idCongTrinh, thang, nam]);
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'bang_luong',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}