import '../data/db_helper.dart';
import '../data/models/CongTrinh.dart';
import 'ApiService.dart';

class SyncService {
  final dbHelper = DBHelper.instance;
  final api = ApiService();

  /// ==============================
  /// 🔄 SYNC ALL
  /// ==============================
  Future<void> syncAll() async {
    await syncCongTrinh();
    await syncNhanVien();
    await syncNhanVienCongTrinh();
    await syncTienDo();
    await syncNhatKy();
    await syncChamCong();
  }

  /// ==============================
  /// 🏗 CONG TRINH
  /// ==============================
  Future<void> syncCongTrinh() async {
    final db = await dbHelper.database;
    final list = await db.query(
      'cong_trinh',
      where: 'is_synced = 0',
    );

    for (var item in list) {
      try {
        if (item['server_id'] == null) {
          final congTrinh = CongTrinh.fromMap(item);
          final res = await api.createCongTrinh(congTrinh);
          await db.update(
            'cong_trinh',
            {
              'server_id': res['id'],
              'is_synced': 1,
            },
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } else if (item['is_deleted'] == 1) {
          final serverId = item['server_id'];
          if (serverId != null) {
            await api.deleteCongTrinh(serverId as int);
          }
          await db.update(
            'cong_trinh',
            {'is_synced': 1},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } else {
          await api.updateCongTrinh(item);
          await db.update(
            'cong_trinh',
            {'is_synced': 1},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        }
      } catch (e) {
        print("❌ Sync cong_trinh lỗi: $e");
      }
    }
  }

  /// ==============================
  /// 👤 NHAN VIEN
  /// ==============================
  Future<void> syncNhanVien() async {
    final db = await dbHelper.database;

    final list = await db.query('nhan_vien', where: 'is_synced = 0');

    for (var item in list) {
      try {
        if (item['server_id'] == null) {
          final res = await api.createNhanVien(item);

          await db.update(
            'nhan_vien',
            {
              'server_id': res['id'],
              'is_synced': 1,
            },
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } else {
          await api.updateNhanVien(item);

          await db.update(
            'nhan_vien',
            {'is_synced': 1},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        }
      } catch (e) {
        print("❌ Sync nhan_vien lỗi: $e");
      }
    }
  }

  /// ==============================
  /// 👷 NHAN VIEN CONG TRINH
  /// ==============================
  Future<void> syncNhanVienCongTrinh() async {
    final db = await dbHelper.database;

    final list = await db.query(
      'nhan_vien_cong_trinh',
      where: 'is_synced = 0',
    );

    for (var item in list) {
      try {
        if (item['server_id'] == null) {
          final res = await api.createNhanVienCongTrinh(item);

          await db.update(
            'nhan_vien_cong_trinh',
            {
              'server_id': res['id'],
              'is_synced': 1,
            },
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } else {
          await api.updateNhanVienCongTrinh(item);

          await db.update(
            'nhan_vien_cong_trinh',
            {'is_synced': 1},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        }
      } catch (e) {
        print("❌ Sync nv_cong_trinh lỗi: $e");
      }
    }
  }

  /// ==============================
  /// 📊 TIEN DO
  /// ==============================
  Future<void> syncTienDo() async {
    final db = await dbHelper.database;

    final list = await db.query(
      'tien_do_cong_trinh',
      where: 'is_synced = 0',
    );

    for (var item in list) {
      try {
        if (item['server_id'] == null) {
          final res = await api.createTienDo(item);

          await db.update(
            'tien_do_cong_trinh',
            {
              'server_id': res['id'],
              'is_synced': 1,
            },
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } else {
          await api.updateTienDo(item);

          await db.update(
            'tien_do_cong_trinh',
            {'is_synced': 1},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        }
      } catch (e) {
        print("❌ Sync tien_do lỗi: $e");
      }
    }
  }

  /// ==============================
  /// 📓 NHAT KY
  /// ==============================
  Future<void> syncNhatKy() async {
    final db = await dbHelper.database;

    final list = await db.query('nhat_ky', where: 'is_synced = 0');

    for (var item in list) {
      try {
        if (item['server_id'] == null) {
          final res = await api.createNhatKy(item);

          await db.update(
            'nhat_ky',
            {
              'server_id': res['id'],
              'is_synced': 1,
            },
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } else {
          await api.updateNhatKy(item);

          await db.update(
            'nhat_ky',
            {'is_synced': 1},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        }
      } catch (e) {
        print("❌ Sync nhat_ky lỗi: $e");
      }
    }
  }

  /// ==============================
  /// 🕒 CHAM CONG
  /// ==============================
  Future<void> syncChamCong() async {
    final db = await dbHelper.database;

    final list = await db.query('cham_cong', where: 'is_synced = 0');

    for (var item in list) {
      try {
        if (item['server_id'] == null) {
          final res = await api.createChamCong(item);

          await db.update(
            'cham_cong',
            {
              'server_id': res['id'],
              'is_synced': 1,
            },
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } else {
          await api.updateChamCong(item);

          await db.update(
            'cham_cong',
            {'is_synced': 1},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        }
      } catch (e) {
        print("❌ Sync cham_cong lỗi: $e");
      }
    }
  }
}