import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/utils/trang_thai_khoa_cong.dart';
import 'package:nhat_ky_xay_dung/core/utils/trang_thai_luong.dart';
import 'package:nhat_ky_xay_dung/core/utils/trang_thai_xoa.dart';
import 'package:nhat_ky_xay_dung/data/tables/bang_luong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/ung_luong_table.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/models/bang_luong.dart';
import 'package:nhat_ky_xay_dung/features/luong/data/enums.dart';
import '../../../../data/db_helper.dart';
import '../../../../data/tables/cham_cong_table.dart';
import '../../../../data/tables/chi_tiet_doi_tru_ung_luong.dart';

class ChotChiLuongRepository {
  final _dbHelper = DBHelper.instance;

  // Chốt hoặc hủy chốt lương dành cho Datacel chốt lương trong bảng chấm công
  Future<void> chotOrHuyChotLuong({
    int? idBangLuong,
    required int idNhanVienCongTrinh,
    required int idBangChamCong,
    double tongCong = 0,
    double tongLuong = 0,
    double tongUng = 0,
    double thucNhan = 0,
  }) async
  {
    // Kiểm tra trạng thái hiện tại
    bool daChotLuong = await checkDaChotLuong(idBangLuong: idBangLuong, idNhanVienCongTrinh: idNhanVienCongTrinh, idBangChamCong: idBangChamCong);
    // Nếu đã chốt lương thì gọi hủy chốt lương
    if(daChotLuong){
      await huyChotLuong(idBangChamCong: idBangChamCong, idNhanVienCongTrinh: idNhanVienCongTrinh, idBangLuong: idBangLuong);
    }else{
      // Nếu chưa chốt lương => gọi chốt lương
      BangLuong bangLuong = BangLuong(
          id: idBangLuong,
          idNhanVienCongTrinh: idNhanVienCongTrinh,
          idBangChamCong: idBangChamCong,
          tongCong: tongCong, tongLuong: tongLuong,
          tongUng: tongUng,
          thucNhan: thucNhan);
      await chotLuong(bangLuong: bangLuong);
    }
  }

  // Chỉ xét cho trường hợp chốt lương
  // update hoặc unsert bảng lương,
  // Xử lý đối trừ khoản tạm ứng
  Future<void> chotLuong({required BangLuong bangLuong}) async
  {
    final db = await _dbHelper.database;
    // Tìm bảng chấm công đã khóa
    final listBangChamCong = await db.query(
      ChamCongTable.tableName,
      columns: [ChamCongTable.daKhoa],
      where: '${ChamCongTable.id} = ? ',
      whereArgs: [bangLuong.idBangChamCong],
    );
    if (listBangChamCong.isEmpty) {
      throw Exception('Không tìm thấy Bảng chấm công.');
    }
    final isDaKhoa = listBangChamCong.first[ChamCongTable.daKhoa];
    if (isDaKhoa == TrangThaiKhoaChamCong.chuakhoa.value) {
      throw Exception('Bảng chấm công chưa khóa. Vui lòng khóa bảng chấm công trước khi chốt lương!');
    }
    final listBangLuong = await db.query(
      BangLuongTable.tableName,
      where: '${BangLuongTable.id} = ? OR (${BangLuongTable.idNhanVienCongTrinh} = ? AND ${BangLuongTable.idBangChamCong} = ?)',
      whereArgs: [bangLuong.id, bangLuong.idNhanVienCongTrinh, bangLuong.idBangChamCong],
    );
    final nowIso = DateTime.now().toIso8601String();
    // Đã có bảng lương => update
    if (listBangLuong.isNotEmpty) {
      bangLuong.id = listBangLuong.first['id'] as int?;
      await db.update(
        BangLuongTable.tableName,
        {
          BangLuongTable.trangThai: TrangThaiLuong.dachot.value,
          BangLuongTable.tongCong: bangLuong.tongCong,
          BangLuongTable.tongLuong: bangLuong.tongLuong,
          BangLuongTable.tongUng : bangLuong.tongUng,
          BangLuongTable.thucNhan: bangLuong.thucNhan,
          BangLuongTable.ngayChot: nowIso,
          BangLuongTable.updated_at: nowIso,
        },
        where: '${BangLuongTable.id} = ?',
        whereArgs: [bangLuong.id],
      );
    }else{
      // Chưa có bảng lương => insert
      bangLuong.id = await db.insert(
        BangLuongTable.tableName,
        {
          BangLuongTable.idNhanVienCongTrinh: bangLuong.idNhanVienCongTrinh,
          BangLuongTable.idBangChamCong: bangLuong.idBangChamCong,
          BangLuongTable.tongCong: bangLuong.tongCong, // Số ngày công
          BangLuongTable.tongLuong: bangLuong.tongLuong,
          BangLuongTable.tongUng: bangLuong.tongUng, // tổng tiền ứng chưa bị trừ
          BangLuongTable.thucNhan: bangLuong.thucNhan,
          BangLuongTable.trangThai: TrangThaiLuong.dachot.value, // Chốt lương
          BangLuongTable.ngayChot: nowIso,
          BangLuongTable.is_synced: 0,
          BangLuongTable.updated_at: nowIso,
          BangLuongTable.is_deleted: 0,
        },
      );
    }
    // Xử lý đối trừ lương
    // 1. Tính tổng lương khả dụng để khấu trừ
    final double tongLuong = bangLuong.tongLuong ?? 0; // Đã sửa: dùng tongLuong thay vì tongCong
    double soTienConDoiTru = tongLuong;

// Lấy danh sách phiếu ứng chưa khấu trừ hết
    final listUngLuong = await db.query(
      UngLuongTable.tableName,
      where: '${UngLuongTable.idNhanVienCongTrinh} = ? '
          'AND (${UngLuongTable.soTien} - IFNULL(${UngLuongTable.soTienDaTru}, 0)) > 0 '
          'AND ${UngLuongTable.is_deleted} = 0',
      whereArgs: [bangLuong.idNhanVienCongTrinh],
      orderBy: '${UngLuongTable.ngayUng} ASC',
    );

    for (var ungLuong in listUngLuong) {
      if (soTienConDoiTru <= 0) break;

      final int idUngLuong = ungLuong[UngLuongTable.id] as int;
      final double soTienGoc = (ungLuong[UngLuongTable.soTien] as num?)?.toDouble() ?? 0.0;
      final double soTienDaTruHienTai = (ungLuong[UngLuongTable.soTienDaTru] as num?)?.toDouble() ?? 0.0;

      // Tính số tiền còn nợ của phiếu này (An toàn với Null)
      final double soTienConNoPhieuNay = soTienGoc - soTienDaTruHienTai;
      if (soTienConNoPhieuNay <= 0) continue;

      // Số tiền thực tế khấu trừ đợt này cho phiếu ứng
      double soTienKhauTru = (soTienConDoiTru >= soTienConNoPhieuNay)
          ? soTienConNoPhieuNay
          : soTienConDoiTru;

      // Lưu chi tiết đối trừ
      await db.insert(
        ChiTietDoiTruUngLuongTable.tableName,
        {
          ChiTietDoiTruUngLuongTable.idBangLuong: bangLuong.id,
          ChiTietDoiTruUngLuongTable.idUngLuong: idUngLuong,
          ChiTietDoiTruUngLuongTable.soTienDoiTru: soTienKhauTru,
          ChiTietDoiTruUngLuongTable.ngayDoiTru: nowIso,
          ChiTietDoiTruUngLuongTable.isSynced: 0,
          ChiTietDoiTruUngLuongTable.updatedAt: nowIso,
          ChiTietDoiTruUngLuongTable.isDeleted: 0,
        },
      );
      // Cập nhật lại số tiền đã trừ vào bảng Ứng Lương
      await db.update(
        UngLuongTable.tableName,
        {
          UngLuongTable.soTienDaTru: soTienDaTruHienTai + soTienKhauTru,
        },
        where: '${UngLuongTable.id} = ?',
        whereArgs: [idUngLuong],
      );
      // Giảm số tiền quỹ lương còn khả dụng để trừ cho các phiếu tiếp theo
      soTienConDoiTru -= soTienKhauTru; // Đã sửa: trừ đi soTienKhauTru
    }
  }

  Future<void> huyChotLuong({int? idBangLuong, int? idNhanVienCongTrinh, int? idBangChamCong}) async {
    final db = await _dbHelper.database;
    // Tìm bảng lương cần hủy
    if(idBangLuong == null && (idNhanVienCongTrinh == null || idBangChamCong == null)){
      throw Exception('Không tìm thấy bảng lương');
    }
    final listBangLuong = await db.query(
      BangLuongTable.tableName,
      where: '${BangLuongTable.id} = ? OR (${BangLuongTable.idNhanVienCongTrinh} = ? AND ${BangLuongTable.idBangChamCong} = ? )',
      whereArgs: [idBangLuong, idNhanVienCongTrinh, idBangChamCong],
    );
    idBangLuong = listBangLuong.first[BangLuongTable.id] as int?;
    await db.transaction((txn) async {
      // 1. Lấy danh sách các khoản ứng đã bị trừ bởi Bảng lương này
      final listDoiTru = await txn.query(
        ChiTietDoiTruUngLuongTable.tableName,
        where: '${ChiTietDoiTruUngLuongTable.idBangLuong} = ?',
        whereArgs: [idBangLuong],
      );
      // 2. Hoàn lại số tiền cho từng phiếu ứng (nếu có cập nhật so_tien_da_tru ở bảng ung_luong)
      for (var item in listDoiTru) {
        final int idUngLuong = item[ChiTietDoiTruUngLuongTable.idUngLuong] as int;
        final double soTienDoiTru = (item[ChiTietDoiTruUngLuongTable.soTienDoiTru] as num).toDouble();
        await txn.rawUpdate('''
        UPDATE ${UngLuongTable.tableName}
        SET ${UngLuongTable.soTienDaTru} = ${UngLuongTable.soTienDaTru} - ?,
            ${UngLuongTable.trangThai} = CASE
              WHEN (${UngLuongTable.soTienDaTru} - ?) <= 0 THEN ${TrangThaiUngLuong.chuaTru.value}
              ELSE ${TrangThaiUngLuong.daTru.value}
            END
        WHERE ${UngLuongTable.id} = ?
      ''', [soTienDoiTru, soTienDoiTru, idUngLuong]);
      }
      // 3. Xóa chi tiết đối trừ
      await txn.delete(
        ChiTietDoiTruUngLuongTable.tableName,
        where: '${ChiTietDoiTruUngLuongTable.idBangLuong} = ?',
        whereArgs: [idBangLuong],
      );
      // 4. Cập nhật trạng thái bảng lương về Chưa chốt (0)
      await txn.update(
        BangLuongTable.tableName,
        {
          BangLuongTable.trangThai: TrangThaiLuong.chuachot.value,
          BangLuongTable.ngayChot: null,
        },
        where: '${BangLuongTable.id} = ?',
        whereArgs: [idBangLuong],
      );
    });
  }

// Get bảng lương của nhân viên công trình
  Future<BangLuong?> getBangLuongForNhanVien( int? idBangChamCong, int? idNhanVienCongTrinh,) async {
    if (idBangChamCong == null || idNhanVienCongTrinh == null) {
      return null;
    }
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      BangLuongTable.tableName,
      where: '${BangLuongTable.idBangChamCong} = ? '
          'AND ${BangLuongTable.idNhanVienCongTrinh} = ? ',
      whereArgs: [idBangChamCong, idNhanVienCongTrinh],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return BangLuong.fromMap(maps.first);
    }
    return null;
  }

  Future<Map<String, dynamic>?> getBangLuong(int idNvct, int idBangChamCong) async
  {
    final db = await _dbHelper.database;
    final result = await db.query(
      BangLuongTable.tableName,
      where: '${BangLuongTable.idNhanVienCongTrinh} = ? AND ${BangLuongTable.idBangChamCong} = ? AND trangThai',
      whereArgs: [idNvct, idBangChamCong, TrangThaiLuong.dachot],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return result.first;
  }

  /// 👉 thêm chi lương
  Future<void> insertChiLuong({
    required int idBangLuong,
    required double soTien,
    String? ghiChu,
  }) async
  {
    final db = await _dbHelper.database;
    await db.insert('chi_luong', {
      'idBangLuong': idBangLuong,
      'soTien': soTien,
      'ngayChi': DateTime.now().toIso8601String(),
      'ghiChu': ghiChu,
    });
  }

  Future<bool> checkDaChotLuong({int? idBangLuong, int? idBangChamCong, int? idNhanVienCongTrinh}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      BangLuongTable.tableName,
      where: '(${BangLuongTable.id} = ? OR ${BangLuongTable.idNhanVienCongTrinh} = ? AND ${BangLuongTable.idBangChamCong} = ?) '
          'AND ${BangLuongTable.trangThai} = ?',
      whereArgs: [
        idBangLuong,
        idNhanVienCongTrinh,
        idBangChamCong,
        TrangThaiLuong.dachot.value
      ],
    );
    return result.isNotEmpty;
  }

  Future<bool> tonTaiDaChotLuong(int? idBangChamCong) async {
    final db = await _dbHelper.database;
    final result = await db.query(
        'bang_luong',
        where: '${BangLuongTable.idBangChamCong} = ? AND trangThai = ?',
        whereArgs: [idBangChamCong, TrangThaiLuong.dachot.value]
    );
    if (result.isEmpty) return false;
    return true;
  }
}