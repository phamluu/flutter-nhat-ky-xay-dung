import 'package:nhat_ky_xay_dung/data/tables/cham_cong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_cong_trinh_table.dart';

class KyLuongTable {
  static const String tableName = 'ky_luong';
  static const String id = 'id';
  static const String idNhanVienCongTrinh = 'idNhanVienCongTrinh';
  static const String idBangChamCong = 'idBangChamCong';
  static const String idPhienChot = 'idPhienChot';
  static const String dotThu = 'dotThu';
  static const String tongCong = 'tongCong';
  static const String tongLuong = 'tongLuong';
  static const String tongUng = 'tongUng';
  static const String thucNhan = 'thucNhan';
  static const String trangThai = 'trangThai';
  static const String ngayChot = 'ngayChot';
  static const String server_id = 'server_id';
  static const String is_synced = 'is_synced';
  static const String updated_at = 'updated_at';
  static const String is_deleted = 'is_deleted';

  static const String createTable = '''
    CREATE TABLE IF NOT EXISTS $tableName (
          $id INTEGER PRIMARY KEY AUTOINCREMENT,
          $idNhanVienCongTrinh INTEGER,
          $idBangChamCong INTEGER,
          $idPhienChot INTEGER,
          $dotThu INTEGER DEFAULT 1,
          $tongCong REAL DEFAULT 0,
          $tongLuong REAL DEFAULT 0,
          $tongUng REAL DEFAULT 0,
          $thucNhan REAL DEFAULT 0,
          $trangThai INTEGER DEFAULT 0, -- 0: chưa chốt, 1: đã chốt, 2: đã chi, 3: Hủy
          $ngayChot TEXT,
          $server_id TEXT,
          $is_synced INTEGER DEFAULT 0,
          $updated_at TEXT,
          $is_deleted INTEGER DEFAULT 0,
          FOREIGN KEY ($idNhanVienCongTrinh) REFERENCES ${NhanVienCongTrinhTable.tableName}(${NhanVienCongTrinhTable.id}) ON DELETE RESTRICT,
          FOREIGN KEY ($idBangChamCong) REFERENCES ${ChamCongTable.tableName}(${ChamCongTable.id}) ON DELETE RESTRICT,
          UNIQUE($idNhanVienCongTrinh, $idBangChamCong, $dotThu)
        )
  ''';
}