import 'package:nhat_ky_xay_dung/core/utils/trang_thai_dong_bo.dart';
import 'package:nhat_ky_xay_dung/core/utils/trang_thai_xoa.dart';
import 'package:nhat_ky_xay_dung/data/models/TienDoCongTrinhModel.dart';
import 'package:nhat_ky_xay_dung/services/sync/ApiNhanVien.dart';
import 'package:nhat_ky_xay_dung/services/sync/ApiNhanVienCongTrinh.dart';
import 'package:nhat_ky_xay_dung/services/sync/ApiNhatKy.dart';
import 'package:nhat_ky_xay_dung/services/sync/ApiTienDo.dart';

import '../data/db_helper.dart';
import '../data/models/ChamCong.dart';
import '../features/cong_trinh/data/models/CongTrinh.dart';
import '../features/nhan_vien/data/models/NhanVien.dart';
import '../features/nhan_vien_cong_trinh/data/models/NhanVienCongTrinh.dart';
import '../features/nhat_ky/data/models/NhatKy.dart';
import 'sync/ApiChamCong.dart';
import 'sync/ApiCongTrinh.dart';

class SyncService {
  final dbHelper = DBHelper.instance;
  final apiCongTrinh = ApiCongTrinh();
  final apiNhanVien = ApiNhanVien();
  final apiNhanVienCongTrinh = ApiNhanVienCongTrinh();
  final apiTienDo = ApiTienDo();
  final apiNhatKy = ApiNhatKy();
  final apiChamCong = ApiChamCong();

  Future<int> getSyncedCount() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT 
        (SELECT COUNT(*) FROM cong_trinh WHERE is_synced = ${TrangThaiDongBo.dadongbo.value}) +
        (SELECT COUNT(*) FROM tien_do_cong_trinh WHERE is_synced = ${TrangThaiDongBo.dadongbo.value}) +
        (SELECT COUNT(*) FROM nhat_ky WHERE is_synced = ${TrangThaiDongBo.dadongbo.value}) +
        (SELECT COUNT(*) FROM nhat_ky_hinh_anh WHERE is_synced = ${TrangThaiDongBo.dadongbo.value}) +
        (SELECT COUNT(*) FROM nhan_vien WHERE is_synced = ${TrangThaiDongBo.dadongbo.value}) +
        (SELECT COUNT(*) FROM nhan_vien_cong_trinh WHERE is_synced = ${TrangThaiDongBo.dadongbo.value}) +
        (SELECT COUNT(*) FROM cham_cong WHERE is_synced = ${TrangThaiDongBo.dadongbo.value}) +
        (SELECT COUNT(*) FROM thu_chi WHERE is_synced = ${TrangThaiDongBo.dadongbo.value}) +
        (SELECT COUNT(*) FROM ung_luong WHERE is_synced = ${TrangThaiDongBo.dadongbo.value}) +
        (SELECT COUNT(*) FROM bang_luong WHERE is_synced = ${TrangThaiDongBo.dadongbo.value}) +
        (SELECT COUNT(*) FROM chi_luong WHERE is_synced = ${TrangThaiDongBo.dadongbo.value}) 
      AS total
    ''');
    return (result.first['total'] as int?) ?? 0;
  }
  Future<int> getUnsyncedCount() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT 
        (SELECT COUNT(*) FROM cong_trinh WHERE is_synced = ${TrangThaiDongBo.chuadongbo.value} OR is_synced IS NULL) +
        (SELECT COUNT(*) FROM tien_do_cong_trinh WHERE is_synced = ${TrangThaiDongBo.chuadongbo.value} OR is_synced IS NULL) +
        (SELECT COUNT(*) FROM nhat_ky WHERE is_synced = ${TrangThaiDongBo.chuadongbo.value} OR is_synced IS NULL) +
        (SELECT COUNT(*) FROM nhat_ky_hinh_anh WHERE is_synced = ${TrangThaiDongBo.chuadongbo.value} OR is_synced IS NULL) +
        (SELECT COUNT(*) FROM nhan_vien WHERE is_synced = ${TrangThaiDongBo.chuadongbo.value} OR is_synced IS NULL) +
        (SELECT COUNT(*) FROM nhan_vien_cong_trinh WHERE is_synced = ${TrangThaiDongBo.chuadongbo.value} OR is_synced IS NULL) +
        (SELECT COUNT(*) FROM cham_cong WHERE is_synced = ${TrangThaiDongBo.chuadongbo.value} OR is_synced IS NULL) +
        (SELECT COUNT(*) FROM thu_chi WHERE is_synced = ${TrangThaiDongBo.chuadongbo.value} OR is_synced IS NULL) +
        (SELECT COUNT(*) FROM ung_luong WHERE is_synced = ${TrangThaiDongBo.chuadongbo.value} OR is_synced IS NULL) +
        (SELECT COUNT(*) FROM bang_luong WHERE is_synced = ${TrangThaiDongBo.chuadongbo.value} OR is_synced IS NULL) +
        (SELECT COUNT(*) FROM chi_luong WHERE is_synced = ${TrangThaiDongBo.chuadongbo.value} OR is_synced IS NULL) 
      AS total
    ''');
    return (result.first['total'] as int?) ?? 0;
  }
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
      where: 'is_synced = ? OR is_synced IS NULL',
      whereArgs: [TrangThaiDongBo.chuadongbo.value],
    );

    for (var item in list) {
      try {
        if (item['server_id'] == null) {
          final congTrinh = CongTrinh.fromMap(item);
          final res = await apiCongTrinh.createCongTrinh(congTrinh);
          await db.update(
            'cong_trinh',
            {
              'server_id': res['id'],
              'is_synced': TrangThaiDongBo.dadongbo.value,
            },
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } else if (item['is_deleted'] == TrangThaiXoa.daxoa.value) {
          final serverId = item['server_id'];
          if (serverId != null) {
            await apiCongTrinh.deleteCongTrinh(serverId as int);
          }
          await db.update(
            'cong_trinh',
            {'is_synced': TrangThaiDongBo.dadongbo.value},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } else {
          final congTrinh = CongTrinh.fromMap(item);
          await apiCongTrinh.updateCongTrinh(congTrinh);
          await db.update(
            'cong_trinh',
            {'is_synced': TrangThaiDongBo.dadongbo.value},
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

    final list = await db.query('nhan_vien',
      where: 'is_synced = ? OR is_synced IS NULL',
      whereArgs: [TrangThaiDongBo.chuadongbo.value],
    );

    for (var item in list) {
      final nhanVien = NhanVien.fromMap(item);
      try {
        if (item['server_id'] == null) {
          final res = await apiNhanVien.createNhanVien(nhanVien);

          await db.update(
            'nhan_vien',
            {
              'server_id': res['id'],
              'is_synced': TrangThaiDongBo.dadongbo.value,
            },
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } else {
          await apiNhanVien.updateNhanVien(nhanVien);

          await db.update(
            'nhan_vien',
            {'is_synced': TrangThaiDongBo.dadongbo.value},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        }
      } catch (e) {
        print("❌ Sync nhan_vien lỗi: $e");
      }
    }
  }
  Future<NhanVien> cancelSyncNhanVien(NhanVien nhanVien) async {
    final db = await dbHelper.database;
    try {
      if (nhanVien.server_id != null) {
        final res =
        await apiNhanVien.deleteNhanVieh(nhanVien.server_id!);
        if (res["success"] != true) {
          throw Exception(res["message"]);
        }
      }
      await db.update(
        'nhan_vien',
        {
          'is_synced': TrangThaiDongBo.chuadongbo.value,
        },
        where: 'id = ?',
        whereArgs: [nhanVien.id],
      );
      nhanVien.isSynced = TrangThaiDongBo.chuadongbo.value;
      return nhanVien;
    } catch (e) {
      print("❌ Hủy sync lỗi: $e");
      rethrow;
    }
  }
  Future<NhanVien?> syncOneNhanVien(NhanVien nhanVien) async {
    final db = await dbHelper.database;
    try {
      if (nhanVien.server_id == null) {
        final res = await apiNhanVien.createNhanVien(nhanVien);
        nhanVien.server_id = res['id'];
        await db.update(
          'nhan_vien',
          {
            'server_id': nhanVien.server_id,
            'is_synced': TrangThaiDongBo.dadongbo.value,
          },
          where: 'id = ?',
          whereArgs: [nhanVien.id],
        );
      } else {
        await apiNhanVien.updateNhanVien(nhanVien);

        await db.update(
          'nhan_vien',
          {'is_synced': TrangThaiDongBo.dadongbo.value},
          where: 'id = ?',
          whereArgs: [nhanVien.id],
        );
      }

      return nhanVien;
    } catch (e) {
      print("❌ Sync lỗi: $e");
      return null;
    }
  }
  /// ==============================
  /// 👷 NHAN VIEN CONG TRINH
  /// ==============================
  Future<void> syncNhanVienCongTrinh() async {
    final db = await dbHelper.database;

    final list = await db.query(
      'nhan_vien_cong_trinh',
      where: 'is_synced = ? OR is_synced IS NULL',
      whereArgs: [TrangThaiDongBo.chuadongbo.value],
    );

    for (var item in list) {
      try {
        final nhanVienCt = NhanVienCongTrinh.fromMap(item);
        if (item['server_id'] == null) {

          final res = await apiNhanVienCongTrinh.create(nhanVienCt);

          await db.update(
            'nhan_vien_cong_trinh',
            {
              'server_id': res['id'],
              'is_synced': TrangThaiDongBo.dadongbo.value,
            },
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } else {
          await apiNhanVienCongTrinh.update(nhanVienCt);

          await db.update(
            'nhan_vien_cong_trinh',
            {'is_synced': TrangThaiDongBo.dadongbo.value},
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
      where: 'is_synced = ? OR is_synced IS NULL',
      whereArgs: [TrangThaiDongBo.chuadongbo.value],
    );

    for (var item in list) {
      try {
        final tienDo = TienDoCongTrinhModel.fromMap(item);
        if (item['server_id'] == null) {
          final res = await apiTienDo.create(tienDo);

          await db.update(
            'tien_do_cong_trinh',
            {
              'server_id': res['id'],
              'is_synced': TrangThaiDongBo.dadongbo.value,
            },
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } else {
          await apiTienDo.update(tienDo);

          await db.update(
            'tien_do_cong_trinh',
            {'is_synced': TrangThaiDongBo.dadongbo.value},
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

    final list = await db.query('nhat_ky',
      where: 'is_synced = ? OR is_synced IS NULL',
      whereArgs: [TrangThaiDongBo.chuadongbo.value],
    );

    for (var item in list) {
      try {
        final nhatKy = NhatKy.fromMap(item);
        if (item['server_id'] == null) {
          final res = await apiNhatKy.create(nhatKy);
          await db.update(
            'nhat_ky',
            {
              'server_id': res['id'],
              'is_synced': TrangThaiDongBo.dadongbo.value,
            },
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } else {
          await apiNhatKy.update(nhatKy);

          await db.update(
            'nhat_ky',
            {'is_synced': TrangThaiDongBo.dadongbo.value},
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

    final list = await db.query('cham_cong',
      where: 'is_synced = ? OR is_synced IS NULL',
      whereArgs: [TrangThaiDongBo.chuadongbo.value],
    );

    for (var item in list) {
      try {
        final chamCong = ChamCong.fromMap(item);
        if (item['server_id'] == null) {
          final res = await apiChamCong.create(chamCong);

          await db.update(
            'cham_cong',
            {
              'server_id': res['id'],
              'is_synced': TrangThaiDongBo.dadongbo.value,
            },
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } else {
          await apiChamCong.update(chamCong);

          await db.update(
            'cham_cong',
            {'is_synced': TrangThaiDongBo.dadongbo.value},
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
