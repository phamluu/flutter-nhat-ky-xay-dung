class ChamCongTable {
  static const String tableName = 'cham_cong';
  static const String createTable = '''
    CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_nhan_vien_cong_trinh INTEGER NOT NULL,
          ngay TEXT NOT NULL,               -- lưu dạng yyyy-MM-dd
          trang_thai_sang INTEGER,          -- 0: nghỉ, 1: đi làm, 2: có phép
          trang_thai_chieu INTEGER,
          tang_ca_bat_dau TEXT,             -- lưu dạng HH:mm
          tang_ca_ket_thuc TEXT,            -- lưu dạng HH:mm
          ghi_chu TEXT,
          ngay_tao TEXT NOT NULL,            -- lưu DateTime.now().toIso8601String()
          server_id TEXT,
          is_synced INTEGER DEFAULT 0,
          updated_at TEXT,
          is_deleted INTEGER DEFAULT 0
      )
  ''';
}