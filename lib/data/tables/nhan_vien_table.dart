class NhanVienTable {
  static const String tableName = 'nhan_vien';
  static const String id = 'id';
  static const String hoTen = 'ho_ten';
  static const String email = 'email';
  static const String soDienThoai = 'so_dien_thoai';
  static const String hinhAnh = 'hinh_anh';
  static const String diaChi = 'dia_chi';
  static const String ngaySinh = 'ngay_sinh';
  static const String userId = 'user_id';
  static const String serverId = 'server_id';
  static const String isSynced = 'is_synced';
  static const String updatedAt = 'updated_at';
  static const String isDeleted = 'is_deleted';
  static const String createTable = '''
    CREATE TABLE $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $hoTen TEXT,
        $email TEXT,
        $soDienThoai TEXT,
        $hinhAnh TEXT,
        $diaChi TEXT,
        $ngaySinh TEXT,
        $userId INTEGER,
        $serverId TEXT,
        $isSynced INTEGER DEFAULT 0,
        $updatedAt TEXT,
        $isDeleted INTEGER DEFAULT 0
      )
  ''';
}