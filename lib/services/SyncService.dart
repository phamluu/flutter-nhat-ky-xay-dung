import 'package:nhat_ky_xay_dung/core/utils/trang_thai_dong_bo.dart';
import 'package:nhat_ky_xay_dung/core/utils/trang_thai_xoa.dart';
import 'package:nhat_ky_xay_dung/data/tables/cham_cong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/chi_luong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/ky_luong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhat_ky_hinh_anh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhat_ky_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/thu_chi_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/tien_do_cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/ung_luong_table.dart';
import 'package:nhat_ky_xay_dung/features/cong_trinh/data/models/TienDoCongTrinhModel.dart';
import 'package:nhat_ky_xay_dung/services/sync/ApiNhanVien.dart';
import 'package:nhat_ky_xay_dung/services/sync/ApiNhanVienCongTrinh.dart';
import 'package:nhat_ky_xay_dung/services/sync/ApiNhatKy.dart';
import 'package:nhat_ky_xay_dung/services/sync/ApiTienDo.dart';

import '../data/db_helper.dart';
import '../data/tables/cong_trinh_table.dart';
import '../features/bang_cham_cong/data/models/cham_cong_chi_tiet.dart';
import '../features/cong_trinh/data/models/CongTrinh.dart';
import '../features/cong_trinh/data/models/NhanVienCongTrinh.dart';
import '../features/cong_trinh/data/models/NhatKyCongTrinh.dart';
import '../features/nhan_vien/data/models/NhanVien.dart';
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
        (SELECT COUNT(*) FROM ${CongTrinhTable.tableName} WHERE ${CongTrinhTable.isSynced} = ${TrangThaiDongBo.dadongbo.value}) +
        (SELECT COUNT(*) FROM ${TienDoCongTrinhTable.tableName} WHERE ${TienDoCongTrinhTable.isSynced} = ${TrangThaiDongBo.dadongbo.value}) +
        (SELECT COUNT(*) FROM ${NhatKyTable.tableName} WHERE ${NhatKyTable.isSynced} = ${TrangThaiDongBo.dadongbo.value}) +
        (SELECT COUNT(*) FROM ${NhatKyHinhAnhTable.tableName} WHERE ${NhatKyHinhAnhTable.isSynced} = ${TrangThaiDongBo.dadongbo.value}) +
        (SELECT COUNT(*) FROM ${NhanVienTable.tableName} WHERE ${NhanVienTable.isSynced} = ${TrangThaiDongBo.dadongbo.value}) +
        (SELECT COUNT(*) FROM ${NhanVienCongTrinhTable.tableName} WHERE ${NhanVienCongTrinhTable.isSynced} = ${TrangThaiDongBo.dadongbo.value}) +
        (SELECT COUNT(*) FROM ${ChamCongTable.tableName} WHERE ${ChamCongTable.isSynced} = ${TrangThaiDongBo.dadongbo.value}) +
        (SELECT COUNT(*) FROM ${ThuChiTable.tableName} WHERE ${ThuChiTable.is_synced} = ${TrangThaiDongBo.dadongbo.value}) +
        (SELECT COUNT(*) FROM ${UngLuongTable.tableName} WHERE ${UngLuongTable.is_synced} = ${TrangThaiDongBo.dadongbo.value}) +
        (SELECT COUNT(*) FROM ${KyLuongTable.tableName} WHERE ${KyLuongTable.is_synced} = ${TrangThaiDongBo.dadongbo.value}) +
        (SELECT COUNT(*) FROM ${ChiLuongTable.tableName} WHERE ${ChiLuongTable.is_synced} = ${TrangThaiDongBo.dadongbo.value}) 
      AS total
    ''');
    return (result.first['total'] as int?) ?? 0;
  }
  Future<int> getUnsyncedCount() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT 
        (SELECT COUNT(*) FROM ${CongTrinhTable.tableName} WHERE is_synced = ${TrangThaiDongBo.chuadongbo.value} OR is_synced IS NULL) +
        (SELECT COUNT(*) FROM ${TienDoCongTrinhTable.tableName} WHERE is_synced = ${TrangThaiDongBo.chuadongbo.value} OR is_synced IS NULL) +
        (SELECT COUNT(*) FROM ${NhatKyTable.tableName} WHERE is_synced = ${TrangThaiDongBo.chuadongbo.value} OR is_synced IS NULL) +
        (SELECT COUNT(*) FROM ${NhatKyHinhAnhTable.tableName} WHERE is_synced = ${TrangThaiDongBo.chuadongbo.value} OR is_synced IS NULL) +
        (SELECT COUNT(*) FROM ${NhanVienTable.tableName} WHERE is_synced = ${TrangThaiDongBo.chuadongbo.value} OR is_synced IS NULL) +
        (SELECT COUNT(*) FROM ${NhanVienCongTrinhTable.tableName} WHERE is_synced = ${TrangThaiDongBo.chuadongbo.value} OR is_synced IS NULL) +
        (SELECT COUNT(*) FROM ${ChamCongTable.tableName} WHERE is_synced = ${TrangThaiDongBo.chuadongbo.value} OR is_synced IS NULL) +
        (SELECT COUNT(*) FROM ${ThuChiTable.tableName} WHERE is_synced = ${TrangThaiDongBo.chuadongbo.value} OR is_synced IS NULL) +
        (SELECT COUNT(*) FROM ${UngLuongTable.tableName} WHERE is_synced = ${TrangThaiDongBo.chuadongbo.value} OR is_synced IS NULL) +
        (SELECT COUNT(*) FROM ${KyLuongTable.tableName} WHERE is_synced = ${TrangThaiDongBo.chuadongbo.value} OR is_synced IS NULL) +
        (SELECT COUNT(*) FROM ${ChiLuongTable.tableName} WHERE is_synced = ${TrangThaiDongBo.chuadongbo.value} OR is_synced IS NULL) 
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
      CongTrinhTable.tableName,
      where: 'is_synced = ? OR is_synced IS NULL',
      whereArgs: [TrangThaiDongBo.chuadongbo.value],
    );

    for (var item in list) {
      try {
        if (item['server_id'] == null) {
          final congTrinh = CongTrinh.fromMap(item);
          final res = await apiCongTrinh.createCongTrinh(congTrinh);
          await db.update(
            CongTrinhTable.tableName,
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
            CongTrinhTable.tableName,
            {'is_synced': TrangThaiDongBo.dadongbo.value},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } else {
          final congTrinh = CongTrinh.fromMap(item);
          await apiCongTrinh.updateCongTrinh(congTrinh);
          await db.update(
            CongTrinhTable.tableName,
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

    final list = await db.query(NhanVienTable.tableName,
      where: 'is_synced = ? OR is_synced IS NULL',
      whereArgs: [TrangThaiDongBo.chuadongbo.value],
    );

    for (var item in list) {
      final nhanVien = NhanVien.fromMap(item);
      try {
        if (item['server_id'] == null) {
          final res = await apiNhanVien.createNhanVien(nhanVien);

          await db.update(
            NhanVienTable.tableName,
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
            NhanVienTable.tableName,
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
        NhanVienTable.tableName,
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
          NhanVienTable.tableName,
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
          NhanVienTable.tableName,
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
      NhanVienCongTrinhTable.tableName,
      where: 'is_synced = ? OR is_synced IS NULL',
      whereArgs: [TrangThaiDongBo.chuadongbo.value],
    );

    for (var item in list) {
      try {
        final nhanVienCt = NhanVienCongTrinh.fromMap(item);
        if (item['server_id'] == null) {

          final res = await apiNhanVienCongTrinh.create(nhanVienCt);

          await db.update(
            NhanVienCongTrinhTable.tableName,
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
            NhanVienCongTrinhTable.tableName,
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
      TienDoCongTrinhTable.tableName,
      where: 'is_synced = ? OR is_synced IS NULL',
      whereArgs: [TrangThaiDongBo.chuadongbo.value],
    );

    for (var item in list) {
      try {
        final tienDo = TienDoCongTrinhModel.fromMap(item);
        if (item['server_id'] == null) {
          final res = await apiTienDo.create(tienDo);

          await db.update(
            TienDoCongTrinhTable.tableName,
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
            TienDoCongTrinhTable.tableName,
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

    final list = await db.query(NhatKyTable.tableName,
      where: 'is_synced = ? OR is_synced IS NULL',
      whereArgs: [TrangThaiDongBo.chuadongbo.value],
    );

    for (var item in list) {
      try {
        final nhatKy = NhatKyCongTrinh.fromMap(item);
        if (item['server_id'] == null) {
          final res = await apiNhatKy.create(nhatKy);
          await db.update(
            NhatKyTable.tableName,
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
            NhatKyTable.tableName,
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

    final list = await db.query(ChamCongTable.tableName,
      where: 'is_synced = ? OR is_synced IS NULL',
      whereArgs: [TrangThaiDongBo.chuadongbo.value],
    );

    for (var item in list) {
      try {
        final chamCong = ChamCongChiTiet.fromMap(item);
        if (item['server_id'] == null) {
          final res = await apiChamCong.create(chamCong);

          await db.update(
            ChamCongTable.tableName,
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
            ChamCongTable.tableName,
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
