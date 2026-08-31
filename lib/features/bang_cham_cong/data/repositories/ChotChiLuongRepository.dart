import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/utils/trang_thai_khoa_cong.dart';
import 'package:nhat_ky_xay_dung/core/utils/trang_thai_luong.dart';
import 'package:nhat_ky_xay_dung/core/utils/trang_thai_xoa.dart';
import 'package:nhat_ky_xay_dung/data/tables/ky_luong_chi_tiet_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/ky_luong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/luong_co_ban_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/ung_luong_table.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/models/bang_luong.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/models/ky_luong_chi_tiet.dart';
import 'package:nhat_ky_xay_dung/features/luong/data/enums.dart';
import 'package:nhat_ky_xay_dung/features/luong/data/models/LuongCoBan.dart';
import '../../../../core/utils/trang_thai_cham_cong.dart';
import '../../../../data/db_helper.dart';
import '../../../../data/tables/cham_cong_chi_tiet_table.dart';
import '../../../../data/tables/cham_cong_table.dart';
import '../../../../data/tables/chi_tiet_doi_tru_ung_luong.dart';
import 'cham_cong_chi_tiet_repo.dart';

class ChotChiLuongRepository {
  final _dbHelper = DBHelper.instance;

  Future<void> chotOrHuyChotLuong({
    int? idBangLuong,
    required int idNhanVienCongTrinh,
    required int idBangChamCong
  }) async
  {
    // Kiểm tra trạng thái hiện tại
    bool daChotLuong = await checkDaChotLuong(idBangLuong: idBangLuong, idNhanVienCongTrinh: idNhanVienCongTrinh, idBangChamCong: idBangChamCong);
    // Nếu đã chốt lương thì gọi hủy chốt lương
    if(daChotLuong){
      await huyChotLuong(idBangChamCong: idBangChamCong, idNhanVienCongTrinh: idNhanVienCongTrinh, idBangLuong: idBangLuong);
    }else{
      // Nếu chưa chốt lương => gọi chốt lương
      await chotLuong(idKyLuong: idBangLuong, idNhanVienCongTrinh: idNhanVienCongTrinh, idBangChamCong: idBangChamCong);
    }
  }
  // Tính lại chốt lương độc lập
  Future<void> chotLuong({int? idKyLuong, int? idNhanVienCongTrinh, int? idBangChamCong}) async {
    final db = await _dbHelper.database;
    bool isDaKhoa = await isKhoaChamCong(idBangChamCong);
    if (!isDaKhoa) {
      throw Exception('Bảng chấm công chưa khóa. Vui lòng khóa bảng chấm công trước khi chốt lương!');
    }

    // Lấy IdBangLuong
    List<Map<String, Object?>> listKyLuong;
    if (idKyLuong != null) {
      listKyLuong = await db.query(
        KyLuongTable.tableName,
        where: '${KyLuongTable.id} = ?',
        whereArgs: [idKyLuong],
        limit: 1,
      );
    } else
    {
      listKyLuong = await db.query(
        KyLuongTable.tableName,
        where:
        '${KyLuongTable.idNhanVienCongTrinh} = ? '
            'AND ${KyLuongTable.idBangChamCong} = ?',
        whereArgs: [
          idNhanVienCongTrinh,
          idBangChamCong,
        ],
        limit: 1,
      );
    }
    // Xử lý kỉ lương chi tiết update or insert
    final listLuongCoBan = await getLichSuLuongCoBan(idNhanVienCongTrinh: idNhanVienCongTrinh!);
    if(listKyLuong.isNotEmpty){
      idKyLuong = listKyLuong.first[KyLuongTable.id] as int?;
    }else{
      idKyLuong = await db.insert(KyLuongTable.tableName,{
        KyLuongTable.idNhanVienCongTrinh: idNhanVienCongTrinh,
        KyLuongTable.idBangChamCong: idBangChamCong,
      });
    }
    double _tongSoCong = 0;
    double _tongLuong = 0;
    double _tongUng = 0;
    await db.transaction((txn) async {
      final listChamCongChiTiet = await txn.query(ChamCongChiTietTable.tableName,
                      where:
                            '${ChamCongChiTietTable.idChamCong} = ? '
                                'AND ${ChamCongChiTietTable.idNhanVienCongTrinh} = ? '
                                'AND ${ChamCongChiTietTable.isDeleted} = 0',
                      whereArgs: [
                        idBangChamCong,
                        idNhanVienCongTrinh,
                      ],
                      orderBy: '${ChamCongChiTietTable.ngay} ASC',
            );
      await txn.delete(
              KyLuongChiTietTable.tableName,
              where: '${KyLuongChiTietTable.idKyLuong} = ?',
              whereArgs: [idKyLuong],
            );
      final batch = txn.batch();
      // Tạo kỳ lương chi tiết
      for (final chamCong in listChamCongChiTiet) {
        final ngay = chamCong[ChamCongChiTietTable.ngay] as String;
        //tính lương cơ bản theo ngày trong listLuongCoBan
        Luongcoban? luongCoBan = timLuongApDung(listLuongCoBan: listLuongCoBan, ngay: ngay);
        final sang = chamCong[ChamCongChiTietTable.trangThaiSang] as int? ?? 0;
        final chieu = chamCong[ChamCongChiTietTable.trangThaiChieu] as int? ?? 0;
        double soCong = 0;
        if (sang == TrangThaiChamCong.coMat.value) {
          soCong += 0.5;
        }
        if (chieu == TrangThaiChamCong.coMat.value) {
          soCong += 0.5;
        }
        final mucLuong = luongCoBan?.mucLuong ?? 0;
        final tienCong = mucLuong * soCong;
        _tongSoCong +=soCong;
        _tongLuong += tienCong;

        final data = KyLuongChiTietModel(
          idChamCongChiTiet: chamCong[ChamCongChiTietTable.id] as int,
          idKyLuong: idKyLuong,
          idLuongCoBan: luongCoBan?.id,
          mucLuong: mucLuong,
          soCong: soCong,
          tienCong: tienCong,
        );
        batch.insert(KyLuongChiTietTable.tableName, data.toMap());
      }
      await batch.commit(noResult: true);
    });
    // Lấy danh sách ứng lương của nhân viên mà chưa đối trừ hết
    final listUngLuong = await db.rawQuery('''
            SELECT *,
              SUM(
                ${UngLuongTable.soTien} -
                IFNULL(${UngLuongTable.soTienDaTru}, 0)
              ) OVER () AS tong_ung
            FROM ${UngLuongTable.tableName}
            WHERE ${UngLuongTable.idNhanVienCongTrinh} = ?
              AND (
                ${UngLuongTable.soTien} -
                IFNULL(${UngLuongTable.soTienDaTru}, 0)
              ) > 0
              AND ${UngLuongTable.is_deleted} = 0
            ORDER BY ${UngLuongTable.ngayUng} ASC
          ''', [idNhanVienCongTrinh]);

    await chotDoiTruLuong(listUngLuong, _tongLuong, idNhanVienCongTrinh, idKyLuong!);
    _tongUng = listUngLuong.isEmpty? 0 : (listUngLuong.first['tong_ung'] as num?)?.toDouble() ?? 0;
    final dataKyLuong = BangLuong(
        idNhanVienCongTrinh: idNhanVienCongTrinh!,
        idBangChamCong: idBangChamCong!,
        tongCong: _tongSoCong,
        tongLuong: _tongLuong,
        tongUng: _tongUng,
        ngayChot: DateTime.now().toIso8601String(),
        thucNhan: _tongLuong - _tongUng,
        trangThai: TrangThaiLuong.dachot.value,
        is_deleted: 0,
    );
    db.update(
        KyLuongTable.tableName,
        dataKyLuong.toMapUpdate(),
        where: '${KyLuongTable.id} = ?',
        whereArgs: [idKyLuong]
    );
  }

  Luongcoban? timLuongApDung({ required List<Luongcoban> listLuongCoBan, required String ngay, }) {
    Luongcoban? luongPhuHop;
    for (final luong in listLuongCoBan) {
      final ngayApDung = luong.ngayApDung;
      if (ngayApDung == null || ngayApDung.isEmpty) {
        luongPhuHop ??= luong;
        continue;
      }
      // Chưa đến ngày áp dụng thì bỏ qua
      if (ngayApDung.compareTo(ngay) <= 0) {
        luongPhuHop = luong;
      }else{
        break;
      }
    }
    return luongPhuHop;
  }

  Future<List<Luongcoban>> getLichSuLuongCoBan({ required int idNhanVienCongTrinh,}) async {
    final db = await _dbHelper.database;
    final rs = await db.rawQuery(
          '''
              SELECT lcb.*
              FROM ${LuongCoBanTable.tableName} lcb
              INNER JOIN ${NhanVienTable.tableName} nv ON lcb.${LuongCoBanTable.idNhanVien} = nv.${NhanVienTable.id}
              INNER JOIN ${NhanVienCongTrinhTable.tableName} nvct ON nv.${NhanVienTable.id} = nvct.${NhanVienCongTrinhTable.idNhanVien}
              WHERE nvct.${NhanVienCongTrinhTable.id} = ? AND lcb.${LuongCoBanTable.isDelete} = 0
              ORDER BY lcb.${LuongCoBanTable.ngayApDung} ASC
              ''',
          [idNhanVienCongTrinh],
        );
        return rs.map((e) => Luongcoban.fromMap(e)).toList();
  }

  // Chốt đối trừ lương
  Future<void> chotDoiTruLuong(listUngLuong, double tongLuong, int idNhanVienCongTrinh, int idBangLuong) async {
    final db = await _dbHelper.database;
    final nowIso = DateTime.now().toIso8601String();
    // Xử lý đối trừ lương
    // 1. Tính tổng lương khả dụng để khấu trừ
    double soTienConDoiTru = tongLuong;

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
          ChiTietDoiTruUngLuongTable.idBangLuong: idBangLuong,
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
  // Chốt hoặc hủy chốt lương dành cho Datacel chốt lương trong bảng chấm công


  // Kiểm tra trạng thái khóa bảng chấm công
  Future<bool> isKhoaChamCong(int? idBangChamCong) async {
    if (idBangChamCong == null) {
      throw Exception('id bảng chấm công không được null.');
    }
    final db = await _dbHelper.database;
    final result = await db.query(
      ChamCongTable.tableName,
      columns: [ChamCongTable.daKhoa],
      where: '${ChamCongTable.id} = ?',
      whereArgs: [idBangChamCong],
      limit: 1,
    );
    if (result.isEmpty) {
      throw Exception('Không tìm thấy bảng chấm công.');
    }
    return result.first[ChamCongTable.daKhoa] == TrangThaiKhoaChamCong.dakhoa.value;
  }

  // Kiểm tra đã chi lương => k cho hủy
  // update trạng thái kỳ lương
  // Xóa chi tiết kì lương
  // xóa đối ứng trừ lương
  Future<void> huyChotLuong({int? idBangLuong, int? idNhanVienCongTrinh, int? idBangChamCong}) async {
    final db = await _dbHelper.database;
    // Tìm bảng lương cần hủy
    if(idBangLuong == null && (idNhanVienCongTrinh == null || idBangChamCong == null)){
      throw Exception('Không tìm thấy bảng lương');
    }
    final listBangLuong = await db.query(
      KyLuongTable.tableName,
      where: '${KyLuongTable.id} = ? OR (${KyLuongTable.idNhanVienCongTrinh} = ? AND ${KyLuongTable.idBangChamCong} = ? )',
      whereArgs: [idBangLuong, idNhanVienCongTrinh, idBangChamCong],
    );
    idBangLuong = listBangLuong.first[KyLuongTable.id] as int?;
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
        KyLuongTable.tableName,
        {
          KyLuongTable.trangThai: TrangThaiLuong.chuachot.value,
          KyLuongTable.ngayChot: null,
        },
        where: '${KyLuongTable.id} = ?',
        whereArgs: [idBangLuong],
      );
      // 5. Xóa chi tiết kì lương
      await txn.delete(KyLuongChiTietTable.tableName,
      where: '${KyLuongChiTietTable.idKyLuong} = ?',
      whereArgs: [idBangLuong]);
    });
  }

// Get bảng lương của nhân viên công trình
  Future<BangLuong?> getBangLuongForNhanVien( int? idBangChamCong, int? idNhanVienCongTrinh,) async {
    if (idBangChamCong == null || idNhanVienCongTrinh == null) {
      return null;
    }
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      KyLuongTable.tableName,
      where: '${KyLuongTable.idBangChamCong} = ? '
          'AND ${KyLuongTable.idNhanVienCongTrinh} = ? ',
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
      KyLuongTable.tableName,
      where: '${KyLuongTable.idNhanVienCongTrinh} = ? AND ${KyLuongTable.idBangChamCong} = ? AND trangThai',
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
      KyLuongTable.tableName,
      where: '(${KyLuongTable.id} = ? OR ${KyLuongTable.idNhanVienCongTrinh} = ? AND ${KyLuongTable.idBangChamCong} = ?) '
          'AND ${KyLuongTable.trangThai} = ?',
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
        KyLuongTable.tableName,
        where: '${KyLuongTable.idBangChamCong} = ? AND ${KyLuongTable.trangThai} = ?',
        whereArgs: [idBangChamCong, TrangThaiLuong.dachot.value]
    );
    if (result.isEmpty) return false;
    return true;
  }

}