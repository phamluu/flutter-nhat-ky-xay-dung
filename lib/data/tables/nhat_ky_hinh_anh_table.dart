class NhatKyHinhAnhTable {
  static const String tableName = 'nhat_ky_hinh_anh';
  static const String createTable = '''
    CREATE TABLE $tableName (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              id_nhat_ky INTEGER NOT NULL,
              url TEXT NOT NULL,
              server_id TEXT,
              is_synced INTEGER DEFAULT 0,
              updated_at TEXT,
              is_deleted INTEGER DEFAULT 0,
              FOREIGN KEY (id_nhat_ky) REFERENCES nhat_ky(id) ON DELETE CASCADE
      )
  ''';
}