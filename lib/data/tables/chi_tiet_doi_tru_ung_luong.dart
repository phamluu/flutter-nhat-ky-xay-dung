class ChiTietDoiTruUngLuongTable {
  static const String tableName = 'chi_tiet_doi_tru_ung_luong';
  static const String id = 'id';
  static const String idBangLuong = 'id_bang_luong';
  static const String idUngLuong = 'id_ung_luong';
  static const String soTienDoiTru = 'so_tien_doi_tru';
  static const String ngayDoiTru = 'ngay_doi_tru';
  static const String serverId = 'server_id';
  static const String isSynced = 'is_synced';
  static const String updatedAt = 'updated_at';
  static const String isDeleted = 'is_deleted';

  static const String createTable = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $id INTEGER PRIMARY KEY AUTOINCREMENT,
      $idBangLuong INTEGER,
      $idUngLuong INTEGER,
      $soTienDoiTru REAL,
      $ngayDoiTru TEXT,
      $serverId INTEGER,
      $isSynced INTEGER DEFAULT 0,
      $updatedAt TEXT,
      $isDeleted INTEGER DEFAULT 0
    )
  ''';
}