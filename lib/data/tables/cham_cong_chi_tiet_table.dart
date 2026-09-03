import 'package:nhat_ky_xay_dung/data/tables/phien_chot_cong_table.dart';

import 'cham_cong_table.dart';

class ChamCongChiTietTable {
  static const String tableName = 'cham_cong_chi_tiet';
  static const String id = 'id';
  static const String idChamCong = 'id_cham_cong';
  static const String idNhanVienCongTrinh = 'id_nhan_vien_cong_trinh';
  static const String ngay = 'ngay';
  static const String trangThaiSang = 'trang_thai_sang';
  static const String trangThaiChieu = 'trang_thai_chieu';
  static const String tangCaBatDau = 'tang_ca_bat_dau';
  static const String tangCaKetthuc = 'tang_ca_ket_thuc';
  static const String ghiChu = 'ghi_chu';
  static const String idPhienChot = 'id_phien_chot';
  static const String serverId = 'server_id';
  static const String isSynced = 'is_synced';
  static const String updatedAt = 'updated_at';
  static const String isDeleted = 'is_deleted';
  static const String createTable = '''
  CREATE TABLE ${ChamCongChiTietTable.tableName} (
    $id INTEGER PRIMARY KEY AUTOINCREMENT,
    $idChamCong INTEGER NOT NULL,                 -- Foreign Key nối tới cham_cong(id)
    $idNhanVienCongTrinh INTEGER NOT NULL,      -- Nhân viên nào
    $ngay TEXT NOT NULL,                            -- Lưu dạng 'yyyy-MM-dd'
    $trangThaiSang INTEGER DEFAULT 0,            -- 0: Nghỉ, 1: Đi làm, 2: Có phép
    $trangThaiChieu INTEGER DEFAULT 0,           -- 0: Nghỉ, 1: Đi làm, 2: Có phép
    $tangCaBatDau TEXT,                        -- HH:mm (vd: '17:30')
    $tangCaKetthuc TEXT,                       -- HH:mm (vd: '19:30')
    $ghiChu TEXT,
    $idPhienChot INTEGER NULL,
    $serverId TEXT,                                -- ID trên Server dùng để sync
    $isSynced INTEGER DEFAULT 0,                  -- 0: Chưa đồng bộ, 1: Đã đồng bộ
    $updatedAt TEXT,
    $isDeleted INTEGER DEFAULT 0,

    -- Ràng buộc: Trong 1 Bảng công, 1 Nhân viên chỉ có 1 dòng dữ liệu cho 1 Ngày
    UNIQUE($idChamCong, $idNhanVienCongTrinh, $ngay),
    FOREIGN KEY ($idPhienChot) REFERENCES ${PhienChotCongTable.tableName}(${PhienChotCongTable.id}) ON DELETE SET NULL
    FOREIGN KEY ($idChamCong) REFERENCES ${ChamCongTable.tableName}(${ChamCongTable.id}) ON DELETE RESTRICT
);

-- Index tăng tốc tìm kiếm chi tiết công theo Bảng chốt công & Nhân viên
CREATE INDEX idx_chi_tiet_cham_cong_parent ON ${ChamCongChiTietTable.tableName}(${ChamCongChiTietTable.idChamCong});
CREATE INDEX idx_chi_tiet_cham_cong_nv ON ${ChamCongChiTietTable.tableName}(${ChamCongChiTietTable.idNhanVienCongTrinh});
  ''';
}