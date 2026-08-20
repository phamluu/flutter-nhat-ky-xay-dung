class UngLuongTable {
  static const String tableName = 'ung_luong';
  static const String createTable = '''
    CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
                idNhanVienCongTrinh INTEGER,
                soTien REAL,
                ngayUng TEXT,     -- lưu dạng ISO8601 (yyyy-MM-dd) hoặc timestamp
                lyDo TEXT,
                server_id TEXT,
                is_synced INTEGER DEFAULT 0,
                updated_at TEXT,
                is_deleted INTEGER DEFAULT 0,
                FOREIGN KEY (idNhanVienCongTrinh) REFERENCES nhan_vien_cong_trinh(id) ON DELETE SET NULL
      )
  ''';
}