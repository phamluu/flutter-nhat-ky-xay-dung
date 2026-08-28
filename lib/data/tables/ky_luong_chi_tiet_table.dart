import 'package:nhat_ky_xay_dung/data/tables/cham_cong_chi_tiet_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/ky_luong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/luong_co_ban_table.dart';

class KyLuongChiTietTable {
  static const String tableName = 'ky_luong_chi_tiet';

  static const String id = 'id';
  static const String idKyLuong = 'id_ky_luong';
  static const String idLuongCoBan = 'id_luong_co_ban';
  static const String idChamCongChiTiet = 'id_cham_cong_chi_tiet';

  static const String mucLuong = 'muc_luong';
  static const String soCong = 'so_cong';
  static const String tienCong = 'tien_cong';

  static const String serverId = 'server_id';
  static const String isSynced = 'is_synced';
  static const String updatedAt = 'updated_at';
  static const String isDeleted = 'is_deleted';

  static const String createTable = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $id INTEGER PRIMARY KEY AUTOINCREMENT,

      $idKyLuong INTEGER NOT NULL,
      $idLuongCoBan INTEGER,
      $idChamCongChiTiet INTEGER NOT NULL,

      $mucLuong REAL DEFAULT 0,
      $soCong REAL DEFAULT 0,
      $tienCong REAL DEFAULT 0,

      $serverId TEXT,
      $isSynced INTEGER DEFAULT 0,
      $updatedAt TEXT,
      $isDeleted INTEGER DEFAULT 0,

      UNIQUE($idKyLuong, $idChamCongChiTiet),

      FOREIGN KEY ($idKyLuong)
        REFERENCES ${KyLuongTable.tableName}(${KyLuongTable.id})
        ON DELETE CASCADE,

      FOREIGN KEY ($idLuongCoBan)
        REFERENCES ${LuongCoBanTable.tableName}(${LuongCoBanTable.id}),

      FOREIGN KEY ($idChamCongChiTiet)
        REFERENCES ${ChamCongChiTietTable.tableName}(${ChamCongChiTietTable.id})
    );

    CREATE INDEX idx_ky_luong_chi_tiet_ky_luong
      ON $tableName($idKyLuong);

    CREATE INDEX idx_ky_luong_chi_tiet_cham_cong
      ON $tableName($idChamCongChiTiet);
  ''';
}