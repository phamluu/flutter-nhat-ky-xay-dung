import 'package:nhat_ky_xay_dung/data/tables/cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_table.dart';
import '../../../../data/db_helper.dart';
import '../models/NhanVienCongTrinh.dart';

class NhanVienCongTrinhService {
  final _dbHelper = DBHelper.instance;

  Future<int> insert(NhanVienCongTrinh item) async {
    final db = await _dbHelper.database;
    return await db.insert('nhan_vien_cong_trinh', item.toMap());
  }

  Future<int> update(NhanVienCongTrinh item) async {
    final db = await _dbHelper.database;
    return await db.update(
      NhanVienCongTrinhTable.tableName,
      item.toMap(),
      where: '${NhanVienCongTrinhTable.id} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'nhan_vien_cong_trinh',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<NhanVienCongTrinh?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'nhan_vien_cong_trinh',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return NhanVienCongTrinh.fromMap(maps.first);
    return null;
  }

  Future<List<NhanVienCongTrinh>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
                SELECT 
                  nvct.${NhanVienCongTrinhTable.id},
                  nvct.${NhanVienCongTrinhTable.idNhanVien},
                  nvct.${NhanVienCongTrinhTable.idCongTrinh},
                  nvct.${NhanVienCongTrinhTable.ngayBatDau},
                  nvct.${NhanVienCongTrinhTable.ngayKetThuc},
                  nvct.${NhanVienCongTrinhTable.vaiTro},
                  nv.${NhanVienTable.hoTen},
                  nv.${NhanVienTable.soDienThoai}
                FROM ${NhanVienCongTrinhTable.tableName} nvct
                LEFT JOIN ${NhanVienTable.tableName} nv 
                  ON nvct.${NhanVienCongTrinhTable.idNhanVien} = nv.id
                LEFT JOIN ${CongTrinhTable.tableName} ct 
                  ON nvct.${NhanVienCongTrinhTable.idCongTrinh} = ct.id
                ORDER BY nvct.${NhanVienCongTrinhTable.id} DESC
        ''');
    return maps.map((e) {
      return NhanVienCongTrinh.fromMap(e);
    }).toList();
  }
  Future<List<NhanVienCongTrinh>> getByCongTrinh(int? idCongTrinh) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
                SELECT 
                  nvct.${NhanVienCongTrinhTable.id},
                  nvct.${NhanVienCongTrinhTable.idNhanVien},
                  nvct.${NhanVienCongTrinhTable.idCongTrinh},
                  nvct.${NhanVienCongTrinhTable.ngayBatDau},
                  nvct.${NhanVienCongTrinhTable.ngayKetThuc},
                  nvct.${NhanVienCongTrinhTable.vaiTro},
                  nv.${NhanVienTable.hoTen},
                  nv.${NhanVienTable.soDienThoai}
                FROM ${NhanVienCongTrinhTable.tableName} nvct
                LEFT JOIN ${NhanVienTable.tableName} nv 
                  ON nvct.${NhanVienCongTrinhTable.idNhanVien} = nv.${NhanVienTable.id}
                LEFT JOIN ${CongTrinhTable.tableName} ct 
                  ON nvct.${NhanVienCongTrinhTable.idCongTrinh} = ct.${CongTrinhTable.id}
                WHERE nvct.${NhanVienCongTrinhTable.idCongTrinh} = ?
                ORDER BY nvct.${NhanVienCongTrinhTable.id} DESC
        ''',[idCongTrinh]);
    return maps.map((e) {
      return NhanVienCongTrinh.fromMap(e);
    }).toList();
  }
  Future<List<NhanVienCongTrinh>> getByNhanVien(int idNhanVien) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      NhanVienCongTrinhTable.tableName,
      where: '${NhanVienCongTrinhTable.idNhanVien} = ?',
      whereArgs: [idNhanVien],
    );
    return maps.map((e) => NhanVienCongTrinh.fromMap(e)).toList();
  }


}
