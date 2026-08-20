class NhatKyTable {
  static const String tableName = 'nhat_ky';
  static const String createTable = '''
    CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ten_nhat_ky TEXT,
        noi_dung TEXT,
        ngay_tao TEXT NOT NULL,
        ngay_trien_khai TEXT,
        id_cong_trinh INTEGER NOT NULL,
        trang_thai INTEGER,
        thoi_tiet_sang INTEGER,
        thoi_tiet_chieu INTEGER,
        server_id TEXT,
        is_synced INTEGER DEFAULT 0,
        updated_at TEXT,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (id_cong_trinh) REFERENCES cong_trinh(id) ON DELETE CASCADE ON UPDATE NO ACTION
      )
  ''';
}