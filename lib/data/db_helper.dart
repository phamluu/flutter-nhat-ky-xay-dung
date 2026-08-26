import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nhat_ky_xay_dung/data/tables/bang_luong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/cham_cong_chi_tiet_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/cham_cong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/chi_luong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/chi_tiet_doi_tru_ung_luong.dart';
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
      version: 8,
      onCreate: (db, version) async {
        await _createAllTables(db);
      },
      onUpgrade: (db, int oldVersion, int newVersion )async{
        if (oldVersion < 8) {
          await _dropAllTables(db);
          await _createAllTables(db);
        }
        if (oldVersion < 7) {
          await db.execute(
              'ALTER TABLE ${UngLuongTable.tableName} ADD COLUMN ${UngLuongTable.soTienDaTru} REAL DEFAULT 0'
          );
        }
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
    await db.execute(BangLuongTable.createTable);
    await db.execute(ChiTietDoiTruUngLuongTable.createTable);
    await db.execute(ChiLuongTable.createTable);
    await db.execute(DanhMucThuChiTable.createTable);
    await db.execute(KhoaChamCongTable.createTable);
    await db.execute(LuongCoBanTable.createTable);
    await db.execute(ThuChiTable.createTable);
    await db.execute(UngLuongTable.createTable);
    await db.execute(ChamCongTable.createTable);
    await db.execute(ChamCongChiTietTable.createTable);
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
