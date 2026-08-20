class NhanVienCongTrinhTable {
  static const String tableName = 'nhan_vien_cong_trinh';
  static const String createTable = '''
    CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
          idNhanVien INTEGER NOT NULL,
          idCongTrinh INTEGER NOT NULL,
          ngayBatDau TEXT,
          ngayKetThuc TEXT,
          vaiTro TEXT,
          server_id TEXT,
          is_synced INTEGER DEFAULT 0,
          updated_at TEXT,
          is_deleted INTEGER DEFAULT 0,
          FOREIGN KEY (idNhanVien) REFERENCES nhan_vien(id),
          FOREIGN KEY (idCongTrinh) REFERENCES cong_trinh(id)
      )
  ''';
}