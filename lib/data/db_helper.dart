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
      version: 9,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade
    );
  }

  Future _onCreate(Database db, int version) async {
    // Tạo bảng lương ghi chốt lương
    await db.execute('''
        CREATE TABLE IF NOT EXISTS bang_luong (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          idNhanVienCongTrinh INTEGER,
          thang INTEGER,
          nam INTEGER,
        
          tongCong REAL DEFAULT 0,
          tongLuong REAL DEFAULT 0,
          tongUng REAL DEFAULT 0,
          thucNhan REAL DEFAULT 0,
        
          trangThai INTEGER DEFAULT 0, -- 0: chưa chi, 1: đã chi
          ngayChot TEXT,
          UNIQUE(idNhanVienCongTrinh, thang, nam)
        )
        ''');
    await db.execute('''
        CREATE TABLE IF NOT EXISTS chi_luong (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          idBangLuong INTEGER,
          soTien REAL NOT NULL,
          ngayChi TEXT NOT NULL,
          ghiChu TEXT,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (idBangLuong) REFERENCES bang_luong(id)
        )
        ''');
    // Tạo bảng công trình
    await db.execute('''
      CREATE TABLE cong_trinh (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ten TEXT NOT NULL,
        dia_chi TEXT,
        hinh_anh TEXT,
        mo_ta TEXT,
        ngay_bat_dau TEXT NOT NULL,
        ngay_ket_thuc TEXT,
        ngay_tao TEXT NOT NULL
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
        id_danh_muc_thu_chi INTEGER,
        loai INTEGER NOT NULL, -- 0: chi, 1: thu
        so_tien REAL NOT NULL,
        ghi_chu TEXT,
        ngay TEXT NOT NULL,
        id_cong_trinh INTEGER,
        ngay_tao TEXT NOT NULL,
        FOREIGN KEY (id_danh_muc_thu_chi) REFERENCES danh_muc_thu_chi(id) ON DELETE SET NULL
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
    // Khóa chấm công
    await db.execute('''
      CREATE TABLE khoa_cham_cong (
        thang TEXT PRIMARY KEY,   -- dạng yyyy-MM
        da_khoa INTEGER DEFAULT 0 -- 0: chưa khóa, 1: đã khóa
      );
    ''');
    // Tạo bảng lương cơ bản
    await db.execute('''
        CREATE TABLE luong_co_ban (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              idNhanVien INTEGER NOT NULL,
              mucLuong REAL,
              ngayTao TEXT NOT NULL DEFAULT (datetime('now')),        -- lưu dạng ISO8601 string (yyyy-MM-dd)
              ngayApDung TEXT,              -- có thể null
              ghiChu TEXT,
              FOREIGN KEY (idNhanVien) REFERENCES nhan_vien(id) ON DELETE CASCADE
          );
     ''');

    // Tạo bảng ứng lương
    await db.execute(''' 
          CREATE TABLE ung_luong (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                idNhanVienCongTrinh INTEGER,
                soTien REAL,
                ngayUng TEXT,     -- lưu dạng ISO8601 (yyyy-MM-dd) hoặc timestamp
                lyDo TEXT,
                FOREIGN KEY (idNhanVienCongTrinh) REFERENCES nhan_vien_cong_trinh(id) ON DELETE SET NULL
            );
    ''');
    await db.execute('''
          CREATE TABLE nhat_ky_hinh_anh (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              id_nhat_ky INTEGER NOT NULL,
              url TEXT NOT NULL,
              FOREIGN KEY (id_nhat_ky) REFERENCES nhat_ky(id) ON DELETE CASCADE
            )
    ''');
  }
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE nhat_ky_hinh_anh (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_nhat_ky INTEGER NOT NULL,
        url TEXT NOT NULL,
        FOREIGN KEY (id_nhat_ky) REFERENCES nhat_ky(id) ON DELETE CASCADE
      )
    ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
      ALTER TABLE cong_trinh ADD COLUMN hinh_anh TEXT
    ''');
    }
    if (oldVersion < 4) {
      // 1. Add column
      await db.execute('''
        ALTER TABLE cong_trinh ADD COLUMN ngay_tao TEXT
      ''');

// 2. Update dữ liệu cũ
      await db.execute('''
          UPDATE cong_trinh 
          SET ngay_tao = datetime('now') 
          WHERE ngay_tao IS NULL
        ''');
    }
    if (oldVersion < 5) {
      // 1. Tạo bảng mới (đã bỏ NOT NULL)
      await db.execute('''
        CREATE TABLE thu_chi_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_danh_muc_thu_chi INTEGER,
          loai INTEGER NOT NULL,
          so_tien REAL NOT NULL,
          ghi_chu TEXT,
          ngay TEXT NOT NULL,
          id_cong_trinh INTEGER,
          ngay_tao TEXT NOT NULL,
          FOREIGN KEY (id_danh_muc_thu_chi) 
            REFERENCES danh_muc_thu_chi(id) ON DELETE SET NULL
        )
      ''');

      // 2. Copy dữ liệu cũ
      await db.execute('''
          INSERT INTO thu_chi_new (
            id, id_danh_muc_thu_chi, loai, so_tien, ghi_chu, ngay, id_cong_trinh, ngay_tao
          )
          SELECT 
            id, id_danh_muc_thu_chi, loai, so_tien, ghi_chu, ngay, id_cong_trinh, ngay_tao
          FROM thu_chi
        ''');

      // 3. Xóa bảng cũ
      await db.execute('DROP TABLE thu_chi');

      // 4. Đổi tên
      await db.execute('ALTER TABLE thu_chi_new RENAME TO thu_chi');
    }
    if (oldVersion < 6) {
      // 1. Tạo bảng mới KHÔNG có idNhanVien
      await db.execute('''
    CREATE TABLE ung_luong_new (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      idNhanVienCongTrinh INTEGER,
      soTien REAL,
      ngayUng TEXT,
      lyDo TEXT,
      FOREIGN KEY (idNhanVienCongTrinh) 
        REFERENCES nhan_vien_cong_trinh(id) ON DELETE SET NULL
    )
  ''');

      // 2. Copy dữ liệu (bỏ cột idNhanVien)
      await db.execute('''
    INSERT INTO ung_luong_new (
      id, idNhanVienCongTrinh, soTien, ngayUng, lyDo
    )
    SELECT 
      id, idNhanVienCongTrinh, soTien, ngayUng, lyDo
    FROM ung_luong
  ''');

      // 3. Xóa bảng cũ
      await db.execute('DROP TABLE ung_luong');

      // 4. Đổi tên
      await db.execute('ALTER TABLE ung_luong_new RENAME TO ung_luong');
    }
    if(oldVersion < 7){
      await db.execute('''
        CREATE TABLE IF NOT EXISTS bang_luong (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          idNhanVienCongTrinh INTEGER,
          thang INTEGER,
          nam INTEGER,
        
          tongCong REAL DEFAULT 0,
          tongLuong REAL DEFAULT 0,
          tongUng REAL DEFAULT 0,
          thucNhan REAL DEFAULT 0,
          ngayChot TEXT,
          UNIQUE(idNhanVienCongTrinh, thang, nam)
        )
        ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS chi_luong (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          idBangLuong INTEGER,
          soTien REAL NOT NULL,
          ngayChi TEXT NOT NULL,
          ghiChu TEXT,
          FOREIGN KEY (idBangLuong) REFERENCES bang_luong(id)
        )
        ''');
    }
    if(oldVersion < 8){
      await db.execute('''
        ALTER TABLE chi_luong ADD COLUMN createdAt TEXT
      ''');
    }
    if(oldVersion < 9){
      await db.execute('''
      CREATE TABLE khoa_cham_cong (
        thang TEXT PRIMARY KEY,   -- dạng yyyy-MM
        da_khoa INTEGER DEFAULT 0 -- 0: chưa khóa, 1: đã khóa
      );
    ''');
    }
  }
}
