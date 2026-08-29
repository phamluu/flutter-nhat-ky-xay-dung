import 'package:nhat_ky_xay_dung/data/tables/cong_trinh_table.dart';

class TienDoCongTrinhTable {
  static const String tableName = 'tien_do_cong_trinh';
  static const String id = 'id';
  static const String idCongTrinh = 'id_cong_trinh';
  static const String tenCongViec = 'ten_cong_viec';
  static const String moTa = 'mo_ta';
  static const String ngayBatDau = 'ngay_bat_dau';
  static const String ngayKetThuc = 'ngay_ket_thuc';
  static const String phanTramKeHoach = 'phan_tram_ke_hoach';
  static const String phanTramThucTe = 'phan_tram_thuc_te';
  static const String trangThai = 'trang_thai';
  static const String trongSo = 'trong_so';
  static const String ngayTao = 'ngay_tao';
  static const String serverId = 'server_id';
  static const String isSynced = 'is_synced';
  static const String updatedAt = 'updated_at';
  static const String isDeleted = 'is_deleted';

  static const String createTable = '''
    CREATE TABLE $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $idCongTrinh INTEGER NOT NULL,
        $tenCongViec TEXT NOT NULL,       -- Tên task (vd: Đổ móng)
        $moTa TEXT,
        $ngayBatDau TEXT,                 -- kế hoạch
        $ngayKetThuc TEXT,                -- deadline
        $phanTramKeHoach REAL DEFAULT 0, -- % dự kiến (optional)
        $phanTramThucTe REAL DEFAULT 0,  -- % thực tế (có thể update từ nhật ký)
        $trangThai INTEGER DEFAULT 0,      -- 0: chưa làm, 1: đang làm, 2: hoàn thành
        $trongSo REAL DEFAULT 1,           -- độ quan trọng (dùng tính tổng tiến độ)
        $ngayTao TEXT NOT NULL DEFAULT (datetime('now')),
        $serverId TEXT,
        $isSynced INTEGER DEFAULT 0,
        $updatedAt TEXT,
        $isDeleted INTEGER DEFAULT 0,
        FOREIGN KEY ($idCongTrinh) REFERENCES ${CongTrinhTable.tableName}(${CongTrinhTable.id}) ON DELETE RESTRICT
      )
  ''';
}