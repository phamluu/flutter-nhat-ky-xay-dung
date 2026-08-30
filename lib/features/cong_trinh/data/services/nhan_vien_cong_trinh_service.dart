import 'package:nhat_ky_xay_dung/data/tables/cham_cong_chi_tiet_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/ung_luong_table.dart';
import '../../../../data/db_helper.dart';
import '../models/NhanVienCongTrinh.dart';

class NhanVienCongTrinhService {
  final _dbHelper = DBHelper.instance;

  Future<int> insert(NhanVienCongTrinh item) async {
    // Kiểm tra mỗi nhân viên chỉ được thêm vào 1 công trình 1 lần
    final db = await _dbHelper.database;
    final isTonTai = await db.query(NhanVienCongTrinhTable.tableName,
        where: '${NhanVienCongTrinhTable.idCongTrinh} = ?'
            'AND ${NhanVienCongTrinhTable.idNhanVien} = ?',
        whereArgs: [item.idCongTrinh, item.idNhanVien],
      limit: 1
    );
    if(isTonTai.isNotEmpty){
      throw Exception('Nhân viên đã tồn tại không thể thêm');
    }
    return await db.insert('nhan_vien_cong_trinh', item.toMap());
  }

  Future<int> update(NhanVienCongTrinh item) async {
    final db = await _dbHelper.database;
    // Lấy idNhanVien cũ
    final oldResult = await db.query(NhanVienCongTrinhTable.tableName,
       columns:  [NhanVienCongTrinhTable.idNhanVien],
      where: '${NhanVienCongTrinhTable.id} = ?',
      whereArgs: [item.id],
      limit: 1
    );
    if(oldResult.isNotEmpty){
      final oldIdNhanVien = oldResult.first[NhanVienCongTrinhTable.idNhanVien];
      if(item.idNhanVien != oldIdNhanVien){
        final isTonTai = await db.query(NhanVienCongTrinhTable.tableName,
            where: '${NhanVienCongTrinhTable.idCongTrinh} = ?'
                'AND ${NhanVienCongTrinhTable.idNhanVien} = ?',
            whereArgs: [item.idCongTrinh, item.idNhanVien],
            limit: 1
        );
        if(isTonTai.isNotEmpty){
          throw Exception('Nhân viên đã tồn tại không thể chọn');
        }
      }
    }

    // Kiểm tra tồn tại
    return await db.update(
      NhanVienCongTrinhTable.tableName,
      item.toMap(),
      where: '${NhanVienCongTrinhTable.id} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    // Kiểm tra có dữ liệu  chấm công, ứng lương
    final results = await Future.wait([
      db.query(
        ChamCongChiTietTable.tableName,
        columns: [ChamCongChiTietTable.idNhanVienCongTrinh],
        where: '${ChamCongChiTietTable.idNhanVienCongTrinh} = ?',
        whereArgs: [id],
        limit: 1,
      ),
      db.query(
        UngLuongTable.tableName,
        columns: [UngLuongTable.idNhanVienCongTrinh],
        where: '${UngLuongTable.idNhanVienCongTrinh} = ?',
        whereArgs: [id],
        limit: 1,
      ),
    ]);
    if (results[0].isNotEmpty) {
      throw Exception('Nhân viên đã có dữ liệu chấm công. Hãy xóa dữ liệu chấm công trước');
    }
    if (results[1].isNotEmpty) {
      throw Exception('Nhân viên đã có dữ liệu ứng lương. Hãy xóa dữ liệu ứng lương trước');
    }
    try{
      return  db.delete(
        NhanVienCongTrinhTable.tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    }catch(e){
      throw Exception('Không thể xóa do nhân viên đã có dữ liệu chấm công hoặc ứng lương liên quan.');
    }
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
