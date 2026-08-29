import 'package:nhat_ky_xay_dung/data/tables/cong_trinh_table.dart';

class NhatKyTable {
  static const String tableName = 'nhat_ky';
  static const String id = 'id';
  static const String tenNhatKy = 'ten_nhat_ky';
  static const String noiDung = 'noi_dung';
  static const String ngayTao = 'ngay_tao';
  static const String ngayTrienKhai = 'ngay_trien_khai';
  static const String idCongTrinh = 'id_cong_trinh';
  static const String trangThai = 'trang_thai';
  static const String thoiTietSang = 'thoi_tiet_sang';
  static const String thoiTietChieu = 'thoi_tiet_chieu';
  static const String serverId = 'server_id';
  static const String isSynced = 'is_synced';
  static const String updatedAt = 'updated_at';
  static const String isDeleted = 'is_deleted';
  static const String createTable = '''
    CREATE TABLE $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $tenNhatKy TEXT,
        $noiDung TEXT,
        $ngayTao TEXT NOT NULL,
        $ngayTrienKhai TEXT,
        $idCongTrinh INTEGER NOT NULL,
        $trangThai INTEGER,
        $thoiTietSang INTEGER,
        $thoiTietChieu INTEGER,
        $serverId TEXT,
        $isSynced INTEGER DEFAULT 0,
        $updatedAt TEXT,
        $isDeleted INTEGER DEFAULT 0,
        FOREIGN KEY ($idCongTrinh) REFERENCES ${CongTrinhTable.tableName}(${CongTrinhTable.id}) ON DELETE RESTRICT
      )
  ''';
}