import 'package:nhat_ky_xay_dung/data/tables/bang_luong_table.dart';

class ChiLuongTable {
  static const String tableName = 'chi_luong';
  static const String id = 'id';
  static const String idBangLuong = 'idBangLuong';
  static const String soTien = 'soTien';
  static const String ngayChi = 'ngayChi';
  static const String ghiChu = 'ghiChu';
  static const String createdAt = 'createdAt';
  static const String server_id = 'server_id';
  static const String is_synced = 'is_synced';
  static const String updated_at = 'updated_at';
  static const String is_deleted = 'is_deleted';
  static const String createTable = '''
    CREATE TABLE IF NOT EXISTS $tableName (
          $id INTEGER PRIMARY KEY AUTOINCREMENT,
          $idBangLuong INTEGER,
          $soTien REAL NOT NULL,
          $ngayChi TEXT NOT NULL,
          $ghiChu TEXT,
          $createdAt TEXT NOT NULL,
          $server_id TEXT,
          $is_synced INTEGER DEFAULT 0,
          $updated_at TEXT,
          $is_deleted INTEGER DEFAULT 0,
          FOREIGN KEY ($idBangLuong) REFERENCES ${BangLuongTable.tableName}(${BangLuongTable.id})
        )
  ''';
}