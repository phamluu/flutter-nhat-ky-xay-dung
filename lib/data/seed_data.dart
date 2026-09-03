import 'package:sqflite/sqflite.dart';
import 'package:nhat_ky_xay_dung/data/tables/cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_table.dart';

import 'tables/nhan_vien_cong_trinh_table.dart';

class SeedData {
  static Future<void> insertSampleData(Database db) async {
    final String today = DateTime.now().toIso8601String().split('T')[0];
    final listCongTrinh = [
      {
        CongTrinhTable.id: 1,
        CongTrinhTable.ten: 'Nhà trường',
        CongTrinhTable.ngayTao: today
      },
      {
        CongTrinhTable.id: 2,
        CongTrinhTable.ten: 'Khu vui chơi',
        CongTrinhTable.ngayTao: today
      },
    ];
    for (var item in listCongTrinh) {
      await db.insert(CongTrinhTable.tableName, item);
    }

    final listNhanVien = [
      {
        NhanVienTable.id: 1,
        NhanVienTable.hoTen: 'Hồ Tùng Mậu',
      },
      {
        NhanVienTable.id: 2,
        NhanVienTable.hoTen: 'Nguyễn Tùng Dương',
      },
      {
        NhanVienTable.id: 3,
        NhanVienTable.hoTen: 'Phạm Mai Anh',
      },
    ];
    for (var item in listNhanVien) {
      await db.insert(NhanVienTable.tableName, item);
    }

    final listNVCT = [
      {
        NhanVienCongTrinhTable.id: 1,
        NhanVienCongTrinhTable.idCongTrinh: 1,
        NhanVienCongTrinhTable.idNhanVien:1
      },
      {
        NhanVienCongTrinhTable.id: 2,
        NhanVienCongTrinhTable.idCongTrinh: 1,
        NhanVienCongTrinhTable.idNhanVien:2
      },
      {
        NhanVienCongTrinhTable.id: 13,
        NhanVienCongTrinhTable.idCongTrinh: 1,
        NhanVienCongTrinhTable.idNhanVien:3,
      },
    ];
    for (var item in listNVCT) {
      await db.insert(NhanVienCongTrinhTable.tableName, item);
    }
  }
}