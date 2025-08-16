import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._internal();
  factory DBHelper() => instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'ptl_app.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade
    );
  }

  Future _onCreate(Database db, int version) async {
    // Tạo bảng công trình
    await db.execute('''
      CREATE TABLE cong_trinh (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ten TEXT NOT NULL,
        dia_chi TEXT,
        mo_ta TEXT,
        ngay_bat_dau TEXT NOT NULL,
        ngay_ket_thuc TEXT
      )
    ''');

    // Tạo bảng nhật ký xây dựng
    await db.execute('''
      CREATE TABLE nhat_ky (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ten_nhat_ky TEXT,
        noi_dung TEXT,
        ngay_tao TEXT NOT NULL,
        ngay_trien_khai TEXT,
        id_cong_trinh INTEGER NOT NULL,
        trang_thai INTEGER,
        thoi_tiet_sang INTEGER,
        thoi_tiet_chieu INTEGER
      )
    ''');

    // Tạo bảng nhân viên
    await db.execute('''
      CREATE TABLE nhan_vien (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ho_ten TEXT,
        email TEXT,
        so_dien_thoai TEXT,
        hinh_anh TEXT,
        dia_chi TEXT,
        ngay_sinh TEXT,
        user_id INTEGER
      )
    ''');

    // Tạo bảng danh mục thu chi
    await db.execute('''
      CREATE TABLE danh_muc_thu_chi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ten TEXT NOT NULL
      )
    ''');

    // Tạo bảng thu chi chi tiết
    await db.execute('''
      CREATE TABLE thu_chi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_danh_muc_thu_chi INTEGER NOT NULL,
        loai INTEGER NOT NULL, -- 0: chi, 1: thu
        so_tien REAL NOT NULL,
        ghi_chu TEXT,
        ngay TEXT NOT NULL,
        id_cong_trinh INTEGER,
        ngay_tao TEXT NOT NULL,
        FOREIGN KEY (id_danh_muc_thu_chi) REFERENCES danh_muc_thu_chi(id)
      )
    ''');

  }
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Version 2: tạo các bảng mới (ngoại trừ cong_trinh)
      await db.execute('''
      CREATE TABLE IF NOT EXISTS nhat_ky (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ten_nhat_ky TEXT,
        noi_dung TEXT,
        ngay_tao TEXT NOT NULL,
        ngay_trien_khai TEXT,
        id_cong_trinh INTEGER NOT NULL,
        trang_thai INTEGER,
        thoi_tiet_sang INTEGER,
        thoi_tiet_chieu INTEGER
      )
    ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS nhan_vien (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ho_ten TEXT,
        email TEXT,
        so_dien_thoai TEXT,
        hinh_anh TEXT,
        dia_chi TEXT,
        ngay_sinh TEXT,
        user_id INTEGER
      )
    ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS danh_muc_thu_chi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ten TEXT NOT NULL
      )
    ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS thu_chi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_danh_muc_thu_chi INTEGER NOT NULL,
        loai INTEGER NOT NULL,
        so_tien REAL NOT NULL,
        ghi_chu TEXT,
        ngay TEXT NOT NULL,
        id_cong_trinh INTEGER,
        ngay_tao TEXT NOT NULL,
        FOREIGN KEY (id_danh_muc_thu_chi) REFERENCES danh_muc_thu_chi(id)
      )
    ''');
    }

    // Sau này nếu version 3,4,... muốn thêm cột hay bảng khác, tiếp tục ở đây
  }


}
