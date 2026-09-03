import 'cham_cong_table.dart';
class PhienChotCongTable{
  static const String tableName = 'phien_chot_cong';
  static const String id = 'id';
  static const String idChamCong = 'id_cham_cong';
  static const String maDot = 'ma_dot';
  static const String denNgay = 'den_ngay';         //'yyyy-MM-dd'
  static const String ngayChot = 'ngay_chot';       //ISO8601 String
  static const String nguoiChot = 'nguoi_chot';     //ID/Tên người thao tác
  static const String ghiChu = 'ghi_chu';
  static const String serverId = 'server_id';
  static const String isSynced = 'is_synced';
  static const String updatedAt = 'updated_at';

  static const String createTable = '''
  CREATE TABLE $tableName (
    $id INTEGER PRIMARY KEY AUTOINCREMENT,
    $idChamCong INTEGER NOT NULL,
    $maDot TEXT,
    $denNgay TEXT NOT NULL,
    $ngayChot TEXT NOT NULL,
    $nguoiChot TEXT,
    $ghiChu TEXT,
    $serverId TEXT,
    $isSynced INTEGER DEFAULT 0,
    $updatedAt TEXT,
    FOREIGN KEY ($idChamCong) REFERENCES ${ChamCongTable.tableName}(${ChamCongTable.id}) ON DELETE RESTRICT
  );
  ''';
}