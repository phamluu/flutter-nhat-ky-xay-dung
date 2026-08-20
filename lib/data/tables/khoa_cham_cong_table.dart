class KhoaChamCongTable {
  static const String tableName = 'khoa_cham_cong';
  static const String createTable = '''
    CREATE TABLE $tableName (
        thang TEXT PRIMARY KEY,   -- dạng yyyy-MM
        da_khoa INTEGER DEFAULT 0, -- 0: chưa khóa, 1: đã khóa
        server_id TEXT,
        is_synced INTEGER DEFAULT 0,
        updated_at TEXT,
        is_deleted INTEGER DEFAULT 0
      )
  ''';
}