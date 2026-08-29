import 'package:nhat_ky_xay_dung/data/tables/cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/danh_muc_thu_chi_table.dart';

class ThuChiTable {
  static const String tableName = 'thu_chi';
  static const String id = 'id';
  static const String id_danh_muc_thu_chi = 'id_danh_muc_thu_chi';
  static const String loai = 'loai';
  static const String so_tien = 'so_tien';
  static const String ghi_chu = 'ghi_chu';
  static const String ngay = 'ngay';
  static const String id_cong_trinh = 'id_cong_trinh';
  static const String ngay_tao = 'ngay_tao';
  static const String server_id = 'server_id';
  static const String is_synced = 'is_synced';
  static const String updated_at = 'updated_at';
  static const String is_deleted = 'is_deleted';
  static const String createTable = '''
    CREATE TABLE $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $id_danh_muc_thu_chi INTEGER,
        $loai INTEGER NOT NULL, -- 0: chi, 1: thu
        $so_tien REAL NOT NULL,
        $ghi_chu TEXT,
        $ngay TEXT NOT NULL,
        $id_cong_trinh INTEGER,
        $ngay_tao TEXT NOT NULL,
        $server_id TEXT,
        $is_synced INTEGER DEFAULT 0,
        $updated_at TEXT,
        $is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY ($id_danh_muc_thu_chi) REFERENCES ${DanhMucThuChiTable.tableName}(${DanhMucThuChiTable.id}) ON DELETE RESTRICT
        FOREIGN KEY ($id_cong_trinh) REFERENCES ${CongTrinhTable.tableName}(${CongTrinhTable.id}) ON DELETE RESTRICT
      )
  ''';
}