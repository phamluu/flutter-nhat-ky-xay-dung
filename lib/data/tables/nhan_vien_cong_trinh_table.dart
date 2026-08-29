import 'package:nhat_ky_xay_dung/data/tables/cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_table.dart';

class NhanVienCongTrinhTable {
  static const String tableName = 'nhan_vien_cong_trinh';
  static const String id = 'id';
  static const String idNhanVien = 'idNhanVien';
  static const String idCongTrinh = 'idCongTrinh';
  static const String ngayBatDau = 'ngayBatDau';
  static const String ngayKetThuc = 'ngayKetThuc';
  static const String vaiTro = 'vaiTro';
  static const String serverId = 'server_id';
  static const String isSynced = 'is_synced';
  static const String updatedAt = 'updated_at';
  static const String isDeleted = 'is_deleted';

  static const String createTable = '''
    CREATE TABLE $tableName (
          $id INTEGER PRIMARY KEY AUTOINCREMENT,
          $idNhanVien INTEGER NOT NULL,
          $idCongTrinh INTEGER NOT NULL,
          $ngayBatDau TEXT,
          $ngayKetThuc TEXT,
          $vaiTro TEXT,
          $serverId TEXT,
          $isSynced INTEGER DEFAULT 0,
          $updatedAt TEXT,
          $isDeleted INTEGER DEFAULT 0,
          FOREIGN KEY ($idNhanVien) REFERENCES ${NhanVienTable.tableName}(${NhanVienTable.id}) ON DELETE RESTRICT,
          FOREIGN KEY ($idCongTrinh) REFERENCES ${CongTrinhTable.tableName}(${CongTrinhTable.id}) ON DELETE RESTRICT
      )
  ''';
}