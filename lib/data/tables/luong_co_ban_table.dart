import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_table.dart';

class LuongCoBanTable {
  static const String tableName = 'luong_co_ban';
  static const String id = 'id';
  static const String idNhanVien = 'idNhanVien';
  static const String mucLuong = 'mucLuong';
  static const String ngayTao = 'ngayTao';
  static const String ngayApDung = 'ngayApDung';
  static const String ghiChu = 'ghiChu';
  static const String serverId = 'server_id';
  static const String isSynced = 'is_synced';
  static const String updatedAt = 'updated_at';
  static const String isDelete = 'is_deleted';

  static const String createTable = '''
    CREATE TABLE $tableName (
              $id INTEGER PRIMARY KEY AUTOINCREMENT,
              $idNhanVien INTEGER NOT NULL,
              $mucLuong REAL,
              $ngayTao TEXT NOT NULL DEFAULT (datetime('now')),        -- lưu dạng ISO8601 string (yyyy-MM-dd)
              $ngayApDung TEXT,              -- có thể null
              $ghiChu TEXT,
              $serverId TEXT,
              $isSynced INTEGER DEFAULT 0,
              $updatedAt TEXT,
              $isDelete INTEGER DEFAULT 0,
              FOREIGN KEY ($idNhanVien) REFERENCES ${NhanVienTable.tableName}(${NhanVienTable.id}) ON DELETE RESTRICT
      )
  ''';
}