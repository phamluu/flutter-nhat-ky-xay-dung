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
      version: 1,
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
        thoi_tiet_chieu INTEGER,
        FOREIGN KEY (id_cong_trinh) REFERENCES cong_trinh(id) ON DELETE CASCADE ON UPDATE NO ACTION
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

    // Tạo bảng nhân viên công trình
    await db.execute('''
        CREATE TABLE nhan_vien_cong_trinh(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          idNhanVien INTEGER NOT NULL,
          idCongTrinh INTEGER NOT NULL,
          ngayBatDau TEXT,
          ngayKetThuc TEXT,
          vaiTro TEXT,
          FOREIGN KEY (idNhanVien) REFERENCES nhan_vien(id),
          FOREIGN KEY (idCongTrinh) REFERENCES cong_trinh(id)
        )
    ''');

    // Tạo bảng chấm công
    await db.execute(''' 
        CREATE TABLE cham_cong (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_nhan_vien_cong_trinh INTEGER NOT NULL,
          ngay TEXT NOT NULL,               -- lưu dạng yyyy-MM-dd
          trang_thai_sang INTEGER,          -- 0: nghỉ, 1: đi làm, 2: có phép
          trang_thai_chieu INTEGER,
          tang_ca_bat_dau TEXT,             -- lưu dạng HH:mm
          tang_ca_ket_thuc TEXT,            -- lưu dạng HH:mm
          ghi_chu TEXT,
          ngay_tao TEXT NOT NULL            -- lưu DateTime.now().toIso8601String()
        );
    ''');

    // Tạo bảng lương cơ bản
    await db.execute('''
        CREATE TABLE luong_co_ban (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              idNhanVien INTEGER NOT NULL,
              mucLuong REAL,
              ngayTao TEXT NOT NULL DEFAULT (datetime('now')),,        -- lưu dạng ISO8601 string (yyyy-MM-dd)
              ngayApDung TEXT,              -- có thể null
              ghiChu TEXT,
              FOREIGN KEY (idNhanVien) REFERENCES nhan_vien(id) ON DELETE CASCADE
          );
     ''');

    // Tạo bảng ứng lương
    await db.execute(''' 
          CREATE TABLE ung_luong (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                idNhanVien INTEGER NOT NULL,
                idNhanVienCongTrinh INTEGER,
                soTien REAL,
                ngayUng TEXT,     -- lưu dạng ISO8601 (yyyy-MM-dd) hoặc timestamp
                lyDo TEXT,
                FOREIGN KEY (idNhanVien) REFERENCES nhan_vien(id) ON DELETE CASCADE,
                FOREIGN KEY (idNhanVienCongTrinh) REFERENCES nhan_vien_cong_trinh(id) ON DELETE SET NULL
            );
    ''');
  }
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {

    // if (oldVersion < 1) {
    //   // Version 1: tạo các bảng mới (ngoại trừ cong_trinh)
    //   await db.execute('''
    //   CREATE TABLE IF NOT EXISTS nhat_ky (
    //     id INTEGER PRIMARY KEY AUTOINCREMENT,
    //     ten_nhat_ky TEXT,
    //     noi_dung TEXT,
    //     ngay_tao TEXT NOT NULL,
    //     ngay_trien_khai TEXT,
    //     id_cong_trinh INTEGER NOT NULL,
    //     trang_thai INTEGER,
    //     thoi_tiet_sang INTEGER,
    //     thoi_tiet_chieu INTEGER
    //   )
    // ''');
    //
    //   await db.execute('''
    //   CREATE TABLE IF NOT EXISTS nhan_vien (
    //     id INTEGER PRIMARY KEY AUTOINCREMENT,
    //     ho_ten TEXT,
    //     email TEXT,
    //     so_dien_thoai TEXT,
    //     hinh_anh TEXT,
    //     dia_chi TEXT,
    //     ngay_sinh TEXT,
    //     user_id INTEGER
    //   )
    // ''');
    //
    //   await db.execute('''
    //   CREATE TABLE IF NOT EXISTS danh_muc_thu_chi (
    //     id INTEGER PRIMARY KEY AUTOINCREMENT,
    //     ten TEXT NOT NULL
    //   )
    // ''');
    //
    //   await db.execute('''
    //   CREATE TABLE IF NOT EXISTS thu_chi (
    //     id INTEGER PRIMARY KEY AUTOINCREMENT,
    //     id_danh_muc_thu_chi INTEGER NOT NULL,
    //     loai INTEGER NOT NULL,
    //     so_tien REAL NOT NULL,
    //     ghi_chu TEXT,
    //     ngay TEXT NOT NULL,
    //     id_cong_trinh INTEGER,
    //     ngay_tao TEXT NOT NULL,
    //     FOREIGN KEY (id_danh_muc_thu_chi) REFERENCES danh_muc_thu_chi(id)
    //   )
    // ''');
    // }
    //
    // // Version 3: Bổ sung liên kết khóa ngoại
    // if (oldVersion < 2) {
    //   await db.execute('''
    //   CREATE TABLE nhat_ky_temp (
    //         id INTEGER PRIMARY KEY AUTOINCREMENT,
    //         ten_nhat_ky TEXT,
    //         noi_dung TEXT,
    //         ngay_tao TEXT NOT NULL,
    //         ngay_trien_khai TEXT,
    //         id_cong_trinh INTEGER NOT NULL,
    //         trang_thai INTEGER,
    //         thoi_tiet_sang INTEGER,
    //         thoi_tiet_chieu INTEGER,
    //         FOREIGN KEY (id_cong_trinh) REFERENCES cong_trinh(id)
    //     );
    //   ''');
    //   await db.execute('''
    //       INSERT INTO nhat_ky_temp (id, ten_nhat_ky, noi_dung, ngay_tao, ngay_trien_khai, id_cong_trinh, trang_thai, thoi_tiet_sang, thoi_tiet_chieu)
    //       SELECT id, ten_nhat_ky, noi_dung, ngay_tao, ngay_trien_khai, id_cong_trinh, trang_thai, thoi_tiet_sang, thoi_tiet_chieu
    //       FROM nhat_ky;
    //   ''');
    //
    //   await db.execute('''
    //       DROP TABLE nhat_ky;
    //   ''');
    //   await db.execute(''' ALTER TABLE nhat_ky_temp RENAME TO nhat_ky; ''');
    // }
    //
    // if (oldVersion < 3){
    //   await db.execute('''
    //     CREATE TABLE nhan_vien_cong_trinh(
    //       id INTEGER PRIMARY KEY AUTOINCREMENT,
    //       idNhanVien INTEGER NOT NULL,
    //       idCongTrinh INTEGER NOT NULL,
    //       ngayBatDau TEXT,
    //       ngayKetThuc TEXT,
    //       vaiTro TEXT,
    //       FOREIGN KEY (idNhanVien) REFERENCES nhan_vien(id),
    //       FOREIGN KEY (idCongTrinh) REFERENCES cong_trinh(id)
    //     )
    // ''');
    // }
    //
    // if(oldVersion < 4){
    //   await db.execute('''
    //     CREATE TABLE cham_cong (
    //       id INTEGER PRIMARY KEY AUTOINCREMENT,
    //       id_nhan_vien_cong_trinh INTEGER NOT NULL,
    //       ngay TEXT NOT NULL,               -- lưu dạng yyyy-MM-dd
    //       trang_thai_sang INTEGER,          -- 0: nghỉ, 1: đi làm, 2: có phép
    //       trang_thai_chieu INTEGER,
    //       tang_ca_bat_dau TEXT,             -- lưu dạng HH:mm
    //       tang_ca_ket_thuc TEXT,            -- lưu dạng HH:mm
    //       ghi_chu TEXT,
    //       ngay_tao TEXT NOT NULL            -- lưu DateTime.now().toIso8601String()
    //     );
    // ''');
    // }
    //
    // if (oldVersion < 5) {
    //   await db.execute('''
    //     CREATE TABLE luong_co_ban (
    //           id INTEGER PRIMARY KEY AUTOINCREMENT,
    //           idNhanVien INTEGER NOT NULL,
    //           mucLuong REAL,
    //           ngayTao TEXT NOT NULL,        -- lưu dạng ISO8601 string (yyyy-MM-dd)
    //           ngayApDung TEXT,              -- có thể null
    //           ghiChu TEXT,
    //           FOREIGN KEY (idNhanVien) REFERENCES nhan_vien(id) ON DELETE CASCADE
    //       );
    //  ''');
    //   // Tạo bảng ứng lương
    //   await db.execute('''
    //       CREATE TABLE ung_luong (
    //             id INTEGER PRIMARY KEY AUTOINCREMENT,
    //             idNhanVien INTEGER NOT NULL,
    //             idNhanVienCongTrinh INTEGER,
    //             soTien REAL,
    //             ngayUng TEXT,     -- lưu dạng ISO8601 (yyyy-MM-dd) hoặc timestamp
    //             lyDo TEXT,
    //             FOREIGN KEY (idNhanVien) REFERENCES nhan_vien(id) ON DELETE CASCADE,
    //             FOREIGN KEY (idNhanVienCongTrinh) REFERENCES nhan_vien_cong_trinh(id) ON DELETE SET NULL
    //         );
    // ''');
    // }
    // Sau này nếu version 3,4,... muốn thêm cột hay bảng khác, tiếp tục ở đây
  }
}
