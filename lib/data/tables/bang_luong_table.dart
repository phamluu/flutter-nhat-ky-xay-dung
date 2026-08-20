class BangLuongTable {
  static const String tableName = 'bang_luong';
  static const String createTable = '''
    CREATE TABLE IF NOT EXISTS bang_luong (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          idNhanVienCongTrinh INTEGER,
          thang INTEGER,
          nam INTEGER,
        
          tongCong REAL DEFAULT 0,
          tongLuong REAL DEFAULT 0,
          tongUng REAL DEFAULT 0,
          thucNhan REAL DEFAULT 0,
        
          trangThai INTEGER DEFAULT 0, -- 0: chưa chốt, 1: đã chốt
          ngayChot TEXT,
          server_id TEXT,
          is_synced INTEGER DEFAULT 0,
          updated_at TEXT,
          is_deleted INTEGER DEFAULT 0,
          UNIQUE(idNhanVienCongTrinh, thang, nam)
        )
  ''';
}