class ChamCongTable{
  static const String tableName = 'bang_cham_cong';
  static const String id = 'id';
  static const String idCongTrinh = 'id_cong_trinh';
  static const String thang = 'thang';
  static const String daKhoa = 'da_khoa';
  static const String ngayTao = 'ngay_tao';
  static const String serverId = 'server_id';
  static const String isSynced = 'is_synced';
  static const String updatedAt = 'updated_at';
  static const String isDeleted = 'is_deleted';

  static const String createTable = '''
  CREATE TABLE $tableName (
    $id INTEGER PRIMARY KEY AUTOINCREMENT,
    $idCongTrinh INTEGER NOT NULL,
    $thang TEXT NOT NULL,                  -- Lưu dạng 'yyyy-MM' (vd: '2026-08')
    $daKhoa INTEGER DEFAULT 0,            -- 0: Chưa khóa, 1: Đã khóa
    $ngayTao TEXT NOT NULL,                -- ISO8601 String: DateTime.now().toIso8601String()
    $serverId TEXT,                        -- ID trên Server dùng để sync
    $isSynced INTEGER DEFAULT 0,          -- 0: Chưa đồng bộ, 1: Đã đồng bộ
    $updatedAt TEXT,                       -- Thời điểm cập nhật cuối
    $isDeleted INTEGER DEFAULT 0,          -- Soft delete (0: Chưa xóa, 1: Đã xóa)

    -- Ràng buộc: 1 Công trình trong 1 Tháng chỉ có duy nhất 1 Bảng chấm công
    UNIQUE($idCongTrinh, $thang)
);

-- Index tăng tốc truy vấn theo công trình và tháng
CREATE INDEX idx_cham_cong_ct_thang ON ${ChamCongTable.tableName}($idCongTrinh, $thang);
  ''';
}