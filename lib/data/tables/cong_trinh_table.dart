class CongTrinhTable {
  static const String tableName = 'cong_trinh';
  static const String id = 'id';
  static const String ten = 'ten';
  static const String diaChi = 'dia_chi';
  static const String hinhAnh = 'hinh_anh';
  static const String moTa = 'mo_ta';
  static const String ngayBatDau = 'ngay_bat_dau';
  static const String ngayKetThuc = 'ngay_ket_thuc';
  static const String ngayTao = 'ngay_tao';
  static const String serverId = 'server_id';
  static const String isSynced = 'is_synced';
  static const String updatedAt = 'updated_at';
  static const String isDeleted = 'is_deleted';
  static const String createTable = '''
    CREATE TABLE $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $ten TEXT NOT NULL,
        $diaChi TEXT,
        $hinhAnh TEXT,
        $moTa TEXT,
        $ngayBatDau TEXT NOT NULL,
        $ngayKetThuc TEXT,
        $ngayTao TEXT NOT NULL,
        $serverId TEXT,
        $isSynced INTEGER DEFAULT 0,
        $updatedAt TEXT,
        $isDeleted INTEGER DEFAULT 0
      )
  ''';
}