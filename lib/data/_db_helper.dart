// import 'dart:io';
//
// import 'package:flutter/foundation.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// class DBHelper {
//   static final DBHelper instance = DBHelper._internal();
//   factory DBHelper() => instance;
//   DBHelper._internal();
//
//   static Database? _db;
//
//   Future<Database> get database async {
//     if (_db != null) return _db!;
//     _db = await _initDB();
//     return _db!;
//   }
//
//   Future<String> _getDatabasePath() async {
//     // Desktop
//     if (!kIsWeb &&
//         (Platform.isWindows ||
//             Platform.isLinux ||
//             Platform.isMacOS)) {
//
//       // Trong quá trình phát triển:
//       final directory = Directory(
//         r'E:\PTLApp\data',
//       );
//
//       if (!await directory.exists()) {
//         await directory.create(
//           recursive: true,
//         );
//       }
//
//       return join(
//         directory.path,
//         'ptl_app.db',
//       );
//     }
//
//     // Android / iOS
//     final databaseDirectory = await getDatabasesPath();
//
//     return join(
//       databaseDirectory,
//       'ptl_app.db',
//     );
//   }
//
//   Future<Database> _initDB() async {
//     final path = await _getDatabasePath();
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _onCreate,
//       onUpgrade: _onUpgrade
//     );
//   }
//   Future<void> resetDB() async {
//     final path = await _getDatabasePath();
//     await deleteDatabase(path);
//   }
//   Future _onCreate(Database db, int version) async {
//     // Tạo bảng lương ghi chốt lương
//     await db.execute('''
//         CREATE TABLE IF NOT EXISTS bang_luong (
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           idNhanVienCongTrinh INTEGER,
//           thang INTEGER,
//           nam INTEGER,
//
//           tongCong REAL DEFAULT 0,
//           tongLuong REAL DEFAULT 0,
//           tongUng REAL DEFAULT 0,
//           thucNhan REAL DEFAULT 0,
//
//           trangThai INTEGER DEFAULT 0, -- 0: chưa chốt, 1: đã chốt
//           ngayChot TEXT,
//           server_id TEXT,
//           is_synced INTEGER DEFAULT 0,
//           updated_at TEXT,
//           is_deleted INTEGER DEFAULT 0,
//           UNIQUE(idNhanVienCongTrinh, thang, nam)
//         )
//         ''');
//     await db.execute('''
//         CREATE TABLE IF NOT EXISTS chi_luong (
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           idBangLuong INTEGER,
//           soTien REAL NOT NULL,
//           ngayChi TEXT NOT NULL,
//           ghiChu TEXT,
//           createdAt TEXT NOT NULL,
//           server_id TEXT,
//           is_synced INTEGER DEFAULT 0,
//           updated_at TEXT,
//           is_deleted INTEGER DEFAULT 0,
//           FOREIGN KEY (idBangLuong) REFERENCES bang_luong(id)
//         )
//         ''');
//     // Tạo bảng công trình
//     await db.execute('''
//       CREATE TABLE cong_trinh (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         ten TEXT NOT NULL,
//         dia_chi TEXT,
//         hinh_anh TEXT,
//         mo_ta TEXT,
//         ngay_bat_dau TEXT NOT NULL,
//         ngay_ket_thuc TEXT,
//         ngay_tao TEXT NOT NULL,
//         server_id TEXT,
//         is_synced INTEGER DEFAULT 0,
//         updated_at TEXT,
//         is_deleted INTEGER DEFAULT 0
//       )
//     ''');
//     // Tạo bảng tiến độ công trình
//     await db.execute('''
//     CREATE TABLE tien_do_cong_trinh (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         id_cong_trinh INTEGER NOT NULL,
//         ten_cong_viec TEXT NOT NULL,       -- Tên task (vd: Đổ móng)
//         mo_ta TEXT,
//         ngay_bat_dau TEXT,                 -- kế hoạch
//         ngay_ket_thuc TEXT,                -- deadline
//         phan_tram_ke_hoach REAL DEFAULT 0, -- % dự kiến (optional)
//         phan_tram_thuc_te REAL DEFAULT 0,  -- % thực tế (có thể update từ nhật ký)
//         trang_thai INTEGER DEFAULT 0,      -- 0: chưa làm, 1: đang làm, 2: hoàn thành
//         trong_so REAL DEFAULT 1,           -- độ quan trọng (dùng tính tổng tiến độ)
//         ngay_tao TEXT NOT NULL DEFAULT (datetime('now')),
//         server_id TEXT,
//         is_synced INTEGER DEFAULT 0,
//         updated_at TEXT,
//         is_deleted INTEGER DEFAULT 0,
//         FOREIGN KEY (id_cong_trinh) REFERENCES cong_trinh(id) ON DELETE CASCADE
//       );
//       '''
//     );
//     // Tạo bảng nhật ký xây dựng
//     await db.execute('''
//       CREATE TABLE nhat_ky (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         ten_nhat_ky TEXT,
//         noi_dung TEXT,
//         ngay_tao TEXT NOT NULL,
//         ngay_trien_khai TEXT,
//         id_cong_trinh INTEGER NOT NULL,
//         trang_thai INTEGER,
//         thoi_tiet_sang INTEGER,
//         thoi_tiet_chieu INTEGER,
//         server_id TEXT,
//         is_synced INTEGER DEFAULT 0,
//         updated_at TEXT,
//         is_deleted INTEGER DEFAULT 0,
//         FOREIGN KEY (id_cong_trinh) REFERENCES cong_trinh(id) ON DELETE CASCADE ON UPDATE NO ACTION
//       )
//     ''');
//
//     // Tạo bảng nhân viên
//     await db.execute('''
//       CREATE TABLE nhan_vien (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         ho_ten TEXT,
//         email TEXT,
//         so_dien_thoai TEXT,
//         hinh_anh TEXT,
//         dia_chi TEXT,
//         ngay_sinh TEXT,
//         user_id INTEGER,
//         server_id TEXT,
//         is_synced INTEGER DEFAULT 0,
//         updated_at TEXT,
//         is_deleted INTEGER DEFAULT 0
//       )
//     ''');
//
//     // Tạo bảng danh mục thu chi
//     await db.execute('''
//       CREATE TABLE danh_muc_thu_chi (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         ten TEXT NOT NULL,
//         server_id TEXT,
//         is_synced INTEGER DEFAULT 0,
//         updated_at TEXT,
//         is_deleted INTEGER DEFAULT 0
//       )
//     ''');
//
//     // Tạo bảng thu chi chi tiết
//     await db.execute('''
//       CREATE TABLE thu_chi (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         id_danh_muc_thu_chi INTEGER,
//         loai INTEGER NOT NULL, -- 0: chi, 1: thu
//         so_tien REAL NOT NULL,
//         ghi_chu TEXT,
//         ngay TEXT NOT NULL,
//         id_cong_trinh INTEGER,
//         ngay_tao TEXT NOT NULL,
//         server_id TEXT,
//         is_synced INTEGER DEFAULT 0,
//         updated_at TEXT,
//         is_deleted INTEGER DEFAULT 0,
//         FOREIGN KEY (id_danh_muc_thu_chi) REFERENCES danh_muc_thu_chi(id) ON DELETE SET NULL
//       )
//     ''');
//
//     // Tạo bảng nhân viên công trình
//     await db.execute('''
//         CREATE TABLE nhan_vien_cong_trinh(
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           idNhanVien INTEGER NOT NULL,
//           idCongTrinh INTEGER NOT NULL,
//           ngayBatDau TEXT,
//           ngayKetThuc TEXT,
//           vaiTro TEXT,
//           server_id TEXT,
//           is_synced INTEGER DEFAULT 0,
//           updated_at TEXT,
//           is_deleted INTEGER DEFAULT 0,
//           FOREIGN KEY (idNhanVien) REFERENCES nhan_vien(id),
//           FOREIGN KEY (idCongTrinh) REFERENCES cong_trinh(id)
//         )
//     ''');
//
//     // Tạo bảng chấm công
//     await db.execute('''
//         CREATE TABLE cham_cong (
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           id_nhan_vien_cong_trinh INTEGER NOT NULL,
//           ngay TEXT NOT NULL,               -- lưu dạng yyyy-MM-dd
//           trang_thai_sang INTEGER,          -- 0: nghỉ, 1: đi làm, 2: có phép
//           trang_thai_chieu INTEGER,
//           tang_ca_bat_dau TEXT,             -- lưu dạng HH:mm
//           tang_ca_ket_thuc TEXT,            -- lưu dạng HH:mm
//           ghi_chu TEXT,
//           ngay_tao TEXT NOT NULL,            -- lưu DateTime.now().toIso8601String()
//           server_id TEXT,
//           is_synced INTEGER DEFAULT 0,
//           updated_at TEXT,
//           is_deleted INTEGER DEFAULT 0
//         );
//     ''');
//     // Khóa chấm công
//     await db.execute('''
//       CREATE TABLE khoa_cham_cong (
//         thang TEXT PRIMARY KEY,   -- dạng yyyy-MM
//         da_khoa INTEGER DEFAULT 0, -- 0: chưa khóa, 1: đã khóa
//         server_id TEXT,
//         is_synced INTEGER DEFAULT 0,
//         updated_at TEXT,
//         is_deleted INTEGER DEFAULT 0
//       );
//     ''');
//     // Tạo bảng lương cơ bản
//     await db.execute('''
//         CREATE TABLE luong_co_ban (
//               id INTEGER PRIMARY KEY AUTOINCREMENT,
//               idNhanVien INTEGER NOT NULL,
//               mucLuong REAL,
//               ngayTao TEXT NOT NULL DEFAULT (datetime('now')),        -- lưu dạng ISO8601 string (yyyy-MM-dd)
//               ngayApDung TEXT,              -- có thể null
//               ghiChu TEXT,
//               server_id TEXT,
//               is_synced INTEGER DEFAULT 0,
//               updated_at TEXT,
//               is_deleted INTEGER DEFAULT 0,
//               FOREIGN KEY (idNhanVien) REFERENCES nhan_vien(id) ON DELETE CASCADE
//           );
//      ''');
//
//     // Tạo bảng ứng lương
//     await db.execute('''
//           CREATE TABLE ung_luong (
//                 id INTEGER PRIMARY KEY AUTOINCREMENT,
//                 idNhanVienCongTrinh INTEGER,
//                 soTien REAL,
//                 ngayUng TEXT,     -- lưu dạng ISO8601 (yyyy-MM-dd) hoặc timestamp
//                 lyDo TEXT,
//                 server_id TEXT,
//                 is_synced INTEGER DEFAULT 0,
//                 updated_at TEXT,
//                 is_deleted INTEGER DEFAULT 0,
//                 FOREIGN KEY (idNhanVienCongTrinh) REFERENCES nhan_vien_cong_trinh(id) ON DELETE SET NULL
//             );
//     ''');
//     await db.execute('''
//           CREATE TABLE nhat_ky_hinh_anh (
//               id INTEGER PRIMARY KEY AUTOINCREMENT,
//               id_nhat_ky INTEGER NOT NULL,
//               url TEXT NOT NULL,
//               server_id TEXT,
//               is_synced INTEGER DEFAULT 0,
//               updated_at TEXT,
//               is_deleted INTEGER DEFAULT 0,
//               FOREIGN KEY (id_nhat_ky) REFERENCES nhat_ky(id) ON DELETE CASCADE
//             )
//     ''');
//   }
//   Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
//     // if (oldVersion < 12){
//     //   resetDB();
//     // }
//   }
// }
