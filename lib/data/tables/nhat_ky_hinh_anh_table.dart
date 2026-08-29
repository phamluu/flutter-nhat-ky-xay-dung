import 'package:nhat_ky_xay_dung/data/tables/nhat_ky_table.dart';

class NhatKyHinhAnhTable {
  static const String tableName = 'nhat_ky_hinh_anh';
  static const String id = 'id';
  static const String idNhatKy = 'id_nhat_ky';
  static const String url = 'url';
  static const String serverId = 'server_id';
  static const String isSynced = 'is_synced';
  static const String updatedAt = 'updated_at';
  static const String isDeleted = 'is_deleted';
  static const String createTable = '''
    CREATE TABLE $tableName (
              $id INTEGER PRIMARY KEY AUTOINCREMENT,
              $idNhatKy INTEGER NOT NULL,
              $url TEXT NOT NULL,
              $serverId TEXT,
              $isSynced INTEGER DEFAULT 0,
              $updatedAt TEXT,
              $isDeleted INTEGER DEFAULT 0,
              FOREIGN KEY (${NhatKyHinhAnhTable.idNhatKy}) REFERENCES ${NhatKyTable.tableName}(${NhatKyTable.id}) ON DELETE CASCADE
      )
  ''';
}