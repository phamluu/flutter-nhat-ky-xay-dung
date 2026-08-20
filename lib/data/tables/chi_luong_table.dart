class ChiLuongTable {
  static const String tableName = 'chi_luong';
  static const String createTable = '''
    CREATE TABLE IF NOT EXISTS chi_luong (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          idBangLuong INTEGER,
          soTien REAL NOT NULL,
          ngayChi TEXT NOT NULL,
          ghiChu TEXT,
          createdAt TEXT NOT NULL,
          server_id TEXT,
          is_synced INTEGER DEFAULT 0,
          updated_at TEXT,
          is_deleted INTEGER DEFAULT 0,
          FOREIGN KEY (idBangLuong) REFERENCES bang_luong(id)
        )
  ''';
}