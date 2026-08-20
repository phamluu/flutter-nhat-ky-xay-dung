import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nhat_ky_xay_dung/data/tables/bang_luong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/cham_cong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/chi_luong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/danh_muc_thu_chi_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/khoa_cham_cong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/luong_co_ban_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhat_ky_hinh_anh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhat_ky_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/thu_chi_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/tien_do_cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/ung_luong_table.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'tables/cong_trinh_table.dart';

class DBHelper{
  static final DBHelper instance = DBHelper._internal();
  factory DBHelper() => instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<String> _getDatabasePath() async {
    // Desktop
    if (!kIsWeb &&
        (Platform.isWindows ||
            Platform.isLinux ||
            Platform.isMacOS)) {

      // Trong quá trình phát triển:
      final directory = Directory(
        r'E:\PTLApp\data',
      );

      if (!await directory.exists()) {
        await directory.create(
          recursive: true,
        );
      }

      return join(
        directory.path,
        'ptl_app.db',
      );
    }

    // Android / iOS
    final databaseDirectory = await getDatabasesPath();

    return join(
      databaseDirectory,
      'ptl_app.db',
    );
  }

  Future<Database> _initDB() async {
    final path = await _getDatabasePath();

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(CongTrinhTable.createTable);
        await db.execute(NhanVienTable.createTable);
        await db.execute(TienDoCongTrinhTable.createTable);
        await db.execute(NhanVienCongTrinhTable.createTable);
        await db.execute(NhatKyTable.createTable);
        await db.execute(NhatKyHinhAnhTable.createTable);
        await db.execute(BangLuongTable.createTable);
        await db.execute(ChamCongTable.createTable);
        await db.execute(ChiLuongTable.createTable);
        await db.execute(DanhMucThuChiTable.createTable);
        await db.execute(KhoaChamCongTable.createTable);
        await db.execute(LuongCoBanTable.createTable);
        await db.execute(ThuChiTable.createTable);
        await db.execute(UngLuongTable.createTable);
        // ...
      },
      onUpgrade: (db, int oldVersion, int newVersion )async{

      }
    );
  }
  Future<void> resetDB() async {
    final path = await _getDatabasePath();
    await deleteDatabase(path);
  }
}
