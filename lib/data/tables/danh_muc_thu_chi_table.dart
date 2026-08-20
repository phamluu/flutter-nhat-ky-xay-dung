class DanhMucThuChiTable {
  static const String tableName = 'danh_muc_thu_chi';
  static const String id = 'id';
  static const String ten = 'ten';
  static const String serverId = 'server_id';
  static const String isSynced = 'is_synced';
  static const String updatedAt = 'updated_at';
  static const String isDeleted = 'is_deleted';

  static const String createTable = '''
    CREATE TABLE $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $ten TEXT NOT NULL,
        $serverId TEXT,
        $isSynced INTEGER DEFAULT 0,
        $updatedAt TEXT,
        $isDeleted INTEGER DEFAULT 0
      )
  ''';
}