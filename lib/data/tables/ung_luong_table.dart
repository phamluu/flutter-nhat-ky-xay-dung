import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_cong_trinh_table.dart';

class UngLuongTable {
  static const String tableName = 'ung_luong';
  static const String id = 'id';
  static const String idNhanVienCongTrinh = 'idNhanVienCongTrinh';
  static const String soTien = 'soTien';
  static const String soTienDaTru = 'so_tien_da_tru';
  static const String ngayUng = 'ngayUng';
  static const String trangThai = 'trang_thai';
  static const String lyDo = 'lyDo';
  static const String server_id = 'server_id';
  static const String is_synced = 'is_synced';
  static const String updated_at = 'updated_at';
  static const String is_deleted = 'is_deleted';

  static const String createTable = '''
    CREATE TABLE $tableName (
                $id INTEGER PRIMARY KEY AUTOINCREMENT,
                $idNhanVienCongTrinh INTEGER,
                $soTien REAL,
                $soTienDaTru REAL,
                $ngayUng TEXT,     -- lưu dạng ISO8601 (yyyy-MM-dd) hoặc timestamp
                $trangThai INTEGER, -- 
                $lyDo TEXT,
                $server_id TEXT,
                $is_synced INTEGER DEFAULT 0,
                $updated_at TEXT,
                $is_deleted INTEGER DEFAULT 0,
                FOREIGN KEY ($idNhanVienCongTrinh) REFERENCES ${NhanVienCongTrinhTable.tableName}(${NhanVienCongTrinhTable.id}) ON DELETE RESTRICT
      )
  ''';
}