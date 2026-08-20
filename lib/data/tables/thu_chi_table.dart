class ThuChiTable {
  static const String tableName = 'thu_chi';
  static const String createTable = '''
    CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_danh_muc_thu_chi INTEGER,
        loai INTEGER NOT NULL, -- 0: chi, 1: thu
        so_tien REAL NOT NULL,
        ghi_chu TEXT,
        ngay TEXT NOT NULL,
        id_cong_trinh INTEGER,
        ngay_tao TEXT NOT NULL,
        server_id TEXT,
        is_synced INTEGER DEFAULT 0,
        updated_at TEXT,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (id_danh_muc_thu_chi) REFERENCES danh_muc_thu_chi(id) ON DELETE SET NULL
      )
  ''';
}