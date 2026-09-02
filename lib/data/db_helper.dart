import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nhat_ky_xay_dung/data/tables/ky_luong_chi_tiet_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/ky_luong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/cham_cong_chi_tiet_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/cham_cong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/chi_luong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/chi_tiet_doi_tru_ung_luong.dart';
import 'package:nhat_ky_xay_dung/data/tables/danh_muc_thu_chi_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/luong_co_ban_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhat_ky_hinh_anh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhat_ky_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/thu_chi_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/tien_do_cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/ung_luong_table.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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

      // sử dụng
      final appDir = await getApplicationSupportDirectory();
      return join(appDir.path, 'ptl_app.db');
      // end sử dụng

      // Trong quá trình phát triển:
      // final directory = Directory( r'E:\PTLApp\data');
      // if (!await directory.exists()) {
      //   await directory.create( recursive: true,);
      // }
      // return join( directory.path, 'ptl_app.db');
      // end
    }

    // Android / iOS
    final databaseDirectory = await getDatabasesPath();
    return join( databaseDirectory, 'ptl_app.db', );
  }

  Future<Database> _initDB() async {
    final path = await _getDatabasePath();
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createAllTables(db);
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onUpgrade: (db, int oldVersion, int newVersion )async{
        // if (oldVersion < 8) {
        //   await _dropAllTables(db);
        //   await _createAllTables(db);
        // }
        // if (oldVersion < 10) {
        //   await db.execute('DROP TABLE IF EXISTS ${KhoaChamCongTable.tableName}');
        // }
      }
    );
  }

  Future<void> _createAllTables(Database db) async {
    await db.execute(CongTrinhTable.createTable);
    await db.execute(NhanVienTable.createTable);
    await db.execute(TienDoCongTrinhTable.createTable);
    await db.execute(NhanVienCongTrinhTable.createTable);
    await db.execute(NhatKyTable.createTable);
    await db.execute(NhatKyHinhAnhTable.createTable);
    await db.execute(KyLuongTable.createTable);
    await db.execute(ChiLuongTable.createTable);
    await db.execute(DanhMucThuChiTable.createTable);
    await db.execute(LuongCoBanTable.createTable);
    await db.execute(ThuChiTable.createTable);
    await db.execute(UngLuongTable.createTable);
    await db.execute(ChamCongTable.createTable);
    await db.execute(ChamCongChiTietTable.createTable);
    await db.execute(KyLuongChiTietTable.createTable);
    await db.execute(ChiTietDoiTruUngLuongTable.createTable);

  }
  Future<void> _dropAllTables(Database db) async {
    final tables = await db.rawQuery('''
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
      AND name NOT LIKE 'sqlite_%'
  ''');

    for (final table in tables) {
      final name = table['name'] as String;
      await db.execute('DROP TABLE IF EXISTS "$name"');
    }
  }
  Future<void> resetDB() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
    final path = await _getDatabasePath();
    await deleteDatabase(path);
  }
}
