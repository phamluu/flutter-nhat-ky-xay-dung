import 'package:nhat_ky_xay_dung/core/utils/trang_thai_khoa_cong.dart';
import 'package:nhat_ky_xay_dung/core/utils/trang_thai_luong.dart';
import 'package:nhat_ky_xay_dung/data/tables/cham_cong_chi_tiet_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/cham_cong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/ky_luong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/phien_chot_cong_table.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/models/bang_luong.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/models/phien_chot_cong.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/ChotChiLuongRepository.dart';
import 'package:nhat_ky_xay_dung/features/luong/data/enums.dart';
import 'package:nhat_ky_xay_dung/features/luong/data/repositories/ung_luong_repository.dart';
import 'package:sqflite/sql.dart';

import '../../../../core/utils/trang_thai_cham_cong.dart';
import '../../../../data/db_helper.dart';
import '../../../../data/tables/chi_tiet_doi_tru_ung_luong.dart';
import '../../../../data/tables/luong_co_ban_table.dart';
import '../../../../data/tables/nhan_vien_cong_trinh_table.dart';
import '../../../../data/tables/nhan_vien_table.dart';
import '../../../../data/tables/ung_luong_table.dart';
import '../../../luong/data/models/LuongCoBan.dart';
import '../models/ChamCongModel.dart';
import '../models/cham_cong_chi_tiet.dart';

class ChamCongLuongRepo {
  final _dbHelper = DBHelper.instance;
  final UngLuongRepository _ungLuongRepo = UngLuongRepository();
  final ChotChiLuongRepository _chotRepo = ChotChiLuongRepository();
  /********************* CHẤM CÔNG **************************/
  Future<void>DeleteData(int? idBangChamCong) async{
    final db = await _dbHelper.database;
    // Kiểm tra bảng chấm công đang khóa => không được xóa
    // Kiểm tra tồn tại kỳ lương đã chốt => không được xóa
    final results = await Future.wait([
        db.query(ChamCongTable.tableName,
                columns: [ChamCongTable.id],
                where: '${ChamCongTable.id} = ? AND ${ChamCongTable.daKhoa} = ${TrangThaiKhoaChamCong.dakhoa.value}',
                whereArgs: [idBangChamCong],
                limit: 1
                ),
      db.query(KyLuongTable.tableName,
          columns: [KyLuongTable.id],
          where: '${KyLuongTable.idPhienChot} = ? AND ${KyLuongTable.trangThai} = ?',
          whereArgs: [idBangChamCong, TrangThaiLuong.dachot.value],
          limit: 1
      )
    ]);
    if(results[0].isNotEmpty){
      throw Exception('Bảng chấm đã khóa. Hãy mở khóa chấm công trước');
    }
    if(results[1].isNotEmpty){
      throw Exception('Bảng chấm công còn tồn tại dữ liệu kỳ lương đã chốt. Hãy hủy chốt lương trước');
    }
    try{
      await db.delete(KyLuongTable.tableName, where: '${KyLuongTable.idPhienChot} = ?',
          whereArgs: [idBangChamCong]);
      await db.delete(ChamCongChiTietTable.tableName, where: '${ChamCongChiTietTable.idChamCong} = ?',
          whereArgs: [idBangChamCong]);
    }catch(e){
      throw Exception('Lỗi: Không thể xóa');
    }
  }

  Future<void> setKhoaChamCong(int? idBangChamCong, DateTime? dateSelected, Set<int>? selectedNhanVienIds ) async {
    if (idBangChamCong == null || dateSelected == null) {
      throw Exception('Thông tin chốt công không hợp lệ');
    }
    final DateTime normalizedDate = DateTime(dateSelected.year, dateSelected.month, dateSelected.day);
    final String dateSelectedStr = normalizedDate.toIso8601String();
    final db = await _dbHelper.database;
    final phienChotCong = await db.query(
        PhienChotCongTable.tableName,
        columns: [PhienChotCongTable.id],
        where: '${PhienChotCongTable.idChamCong} = ? AND ${PhienChotCongTable.denNgay} = ?',
        whereArgs: [idBangChamCong, dateSelectedStr]
    );
    if (phienChotCong.isNotEmpty) {
      throw Exception('Đã tồn tại phiên chốt công cho ngày này');
    }
    try {
      await db.transaction((txn) async {
        final dotChotList = await txn.query(
            PhienChotCongTable.tableName,
            columns: [PhienChotCongTable.id],
            where: '${PhienChotCongTable.idChamCong} = ?',
            whereArgs: [idBangChamCong]
        );
        int dotChotIndex = dotChotList.length + 1;
        final phienChot = PhienChotCong(
          idChamCong: idBangChamCong,
          maDot: dotChotIndex.toString(),
          denNgay: dateSelectedStr,
        );
        final idPhienChot = await txn.insert(
            PhienChotCongTable.tableName,
            phienChot.toMapInsert()
        );

        if (selectedNhanVienIds != null && selectedNhanVienIds.isNotEmpty) {
          final batch = txn.batch();
          for (final idNV in selectedNhanVienIds) {
            batch.update(
                ChamCongChiTietTable.tableName,
                {
                  ChamCongChiTietTable.idPhienChot: idPhienChot
                },
                where: '${ChamCongChiTietTable
                    .idChamCong} = ? AND ${ChamCongChiTietTable
                    .idNhanVienCongTrinh} = ? '
                    'AND date(${ChamCongChiTietTable
                    .ngay}) <= date(?) AND ${ChamCongChiTietTable.idPhienChot} IS NULL',
                whereArgs: [idBangChamCong, idNV, dateSelectedStr]
            );
          }
          await batch.commit(noResult: true);
        }
      });
    }catch(e){
      throw Exception(e);
    }
  }

  Future<List<PhienChotCong>> phienChotCongs(int? idBangChamCong) async {
    if (idBangChamCong == null) return [];
    final db = await _dbHelper.database;
    final String sql = '''
    SELECT 
      p.*,
      COUNT(DISTINCT c.${ChamCongChiTietTable.idNhanVienCongTrinh}) AS so_luong_nv
    FROM ${PhienChotCongTable.tableName} p
    LEFT JOIN ${ChamCongChiTietTable.tableName} c ON p.id = c.${ChamCongChiTietTable.idPhienChot}
    WHERE p.${PhienChotCongTable.idChamCong} = ?
    GROUP BY p.id
    ORDER BY p.id DESC
  ''';
    final rs = await db.rawQuery(sql, [idBangChamCong]);
    return rs.map((map) => PhienChotCong.fromMap(map)).toList();
  }
  Future<void> huyKhoaChamCong(int? idPhienChot) async {
    if (idPhienChot == null) return;
    final db = await _dbHelper.database;
    try{
      await db.transaction((txn) async {
        await txn.update(
          ChamCongChiTietTable.tableName, // Tên bảng chấm công của bạn
          {
            ChamCongChiTietTable.idPhienChot: null,
          },
          where: '${ChamCongChiTietTable.idPhienChot} = ?',
          whereArgs: [idPhienChot],
        );
        await txn.delete(
          PhienChotCongTable.tableName,
          where: '${PhienChotCongTable.id} = ?',
          whereArgs: [idPhienChot],
        );
      });
    }catch(e){
      throw Exception(e);
    }
  }

  /// Lấy danh sách chấm công và tổng lương của từng nhân viên theo đợt chốt công
  Future<List<ChamCongLuongNhanVien>> chamCongNhanVienPhienChot(int? idPhien) async {
    if (idPhien == null) return [];
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT 
        cc.${ChamCongChiTietTable.id} AS idChamCongChiTiet,
        cc.${ChamCongChiTietTable.ngay},
        cc.${ChamCongChiTietTable.trangThaiSang},
        cc.${ChamCongChiTietTable.trangThaiChieu},
        cc.${ChamCongChiTietTable.ghiChu},
        nvct.${NhanVienCongTrinhTable.id} AS idNhanVienCongTrinh,
        nvct.${NhanVienCongTrinhTable.vaiTro},
        nv.${NhanVienTable.id} AS idNhanVien,
        nv.${NhanVienTable.hoTen},
        nv.${NhanVienTable.soDienThoai},
        (
          SELECT lcb.${LuongCoBanTable.mucLuong}
          FROM ${LuongCoBanTable.tableName} lcb
          WHERE lcb.${LuongCoBanTable.idNhanVien} = nv.${NhanVienTable.id}
            AND (lcb.${LuongCoBanTable.ngayApDung} IS NULL OR date(lcb.${LuongCoBanTable.ngayApDung}) <= date(cc.${ChamCongChiTietTable.ngay}))
          ORDER BY lcb.${LuongCoBanTable.ngayApDung} DESC
          LIMIT 1
        ) AS luongNgay
      FROM ${ChamCongChiTietTable.tableName} cc
      INNER JOIN ${NhanVienCongTrinhTable.tableName} nvct 
        ON cc.${ChamCongChiTietTable.idNhanVienCongTrinh} = nvct.${NhanVienCongTrinhTable.id}
      INNER JOIN ${NhanVienTable.tableName} nv 
        ON nvct.${NhanVienCongTrinhTable.idNhanVien} = nv.${NhanVienTable.id}
      WHERE cc.${ChamCongChiTietTable.idPhienChot} = ?
      ORDER BY nvct.${NhanVienCongTrinhTable.id} ASC, cc.${ChamCongChiTietTable.ngay} ASC
    ''', [idPhien]);
    if (results.isEmpty) return [];
    final Map<int, ChamCongLuongNhanVien> resultMap = {};
    for (final row in results) {
      final idNvct = row['idNhanVienCongTrinh'] as int;
      final tongUng = await _ungLuongRepo.tongUngForPhienChot(idPhien, idNvct);
      final tongUngDaTru = await _ungLuongRepo.tongTruUngForPhienChot(idPhien, idNvct);
      if (!resultMap.containsKey(idNvct)) {
        resultMap[idNvct] = ChamCongLuongNhanVien(
          idNhanVienCongTrinh: idNvct,
          hoTen: row[NhanVienTable.hoTen] as String?,
          soDienThoai: row[NhanVienTable.soDienThoai] as String?,
          chucVu: row[NhanVienCongTrinhTable.vaiTro] as String?,
          data: {},
          tongUng: tongUng,
          tongUngDaTru: tongUngDaTru
        );
      }
      final ngay = row[ChamCongChiTietTable.ngay] as String;
      final sang = TrangThaiChamCong.fromValue(row[ChamCongChiTietTable.trangThaiSang] as int?);
      final chieu = TrangThaiChamCong.fromValue(row[ChamCongChiTietTable.trangThaiChieu] as int?);
      final luongNgay = (row['luongNgay'] as num?)?.toDouble() ?? 0.0;
      final chamCong = ChamCongNgay(
        id: row['idChamCongChiTiet'] as int?,
        sang: sang,
        chieu: chieu,
        ghiChu: (row[ChamCongChiTietTable.ghiChu] ?? '').toString(),
      );
      resultMap[idNvct]!.data[ngay] = ChamCongNgayLuong(
        chamCong: chamCong,
        luongNgay: luongNgay,
      );
    }
    return resultMap.values.toList();
  }

  /*********************************LƯƠNG******************************************/
  // Tính lại chốt lương độc lập
  // Nếu chưa chốt thì insert
  // Nếu đã chốt thì update chốt lại
  Future<void> chotLuongTheoDanhSach({
    required List<ChamCongLuongNhanVien> danhSachDuocChon,
    int? idPhienChot,
  }) async {
    if (danhSachDuocChon.isEmpty) return;

    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      for (var nv in danhSachDuocChon) {
        if (nv.idNhanVienCongTrinh == null) continue;

        // 1. Tìm hoặc khởi tạo idKyLuong
        int idKyLuong;
        final kyLuong = await txn.query(
          KyLuongTable.tableName,
          columns: [KyLuongTable.id],
          where: '${KyLuongTable.idNhanVienCongTrinh} = ? AND ${KyLuongTable.idPhienChot} = ?',
          whereArgs: [nv.idNhanVienCongTrinh, idPhienChot],
          limit: 1,
        );

        if (kyLuong.isEmpty) {
          // Tạo bản ghi tạm để lấy idKyLuong
          idKyLuong = await txn.insert(
            KyLuongTable.tableName,
            {
              KyLuongTable.idPhienChot: idPhienChot,
              KyLuongTable.idNhanVienCongTrinh: nv.idNhanVienCongTrinh,
            },
          );
        } else {
          idKyLuong = kyLuong.first[KyLuongTable.id] as int;
        }

        // 2. Xử lý đối ứng trừ lương
        final listUngLuong = await txn.rawQuery('''
        SELECT *,
          SUM(
            ${UngLuongTable.soTien} - IFNULL(${UngLuongTable.soTienDaTru}, 0)
          ) OVER () AS tong_ung
        FROM ${UngLuongTable.tableName}
        WHERE ${UngLuongTable.idNhanVienCongTrinh} = ?
          AND (${UngLuongTable.soTien} - IFNULL(${UngLuongTable.soTienDaTru}, 0)) > 0
          AND ${UngLuongTable.is_deleted} = 0
        ORDER BY ${UngLuongTable.ngayUng} ASC
      ''', [nv.idNhanVienCongTrinh]);

        // Lưu ý: Đảm bảo chotDoiTruLuong nhận 'txn' để chạy cùng transaction
        await _chotRepo.chotDoiTruLuong(
          listUngLuong,
          nv.tongLuong,
          nv.idNhanVienCongTrinh!,
          idKyLuong,
        );

        // Tính tổng số tiền thực tế đã trừ ứng lương
        final truUngResult = await txn.rawQuery('''
        SELECT COALESCE(SUM(${ChiTietDoiTruUngLuongTable.soTienDoiTru}), 0) AS total_tru
        FROM ${ChiTietDoiTruUngLuongTable.tableName}
        WHERE ${ChiTietDoiTruUngLuongTable.idBangLuong} = ?
      ''', [idKyLuong]);

        final double tongTruUng = (truUngResult.first['total_tru'] as num).toDouble();
        final double thucNhan = nv.tongLuong - tongTruUng;

        // 3. Update lại thông tin kỳ lương đã chốt hoàn chỉnh (dùng update thay vì insert replace)
        final Map<String, dynamic> values = {
          KyLuongTable.tongCong: nv.soCong,
          KyLuongTable.tongLuong: nv.tongLuong,
          KyLuongTable.tongUng: tongTruUng,
          KyLuongTable.thucNhan: thucNhan,
          KyLuongTable.trangThai: TrangThaiLuong.dachot.value,
          KyLuongTable.ngayChot: DateTime.now().toIso8601String(),
        };

        await txn.update(
          KyLuongTable.tableName,
          values,
          where: '${KyLuongTable.id} = ?',
          whereArgs: [idKyLuong],
        );
      }
    });
  }
  Future<double> tongLuongChotForNhanVien({ int? idNhanVienCongTrinh, int? idBangChamCong, }) async {
    final db = await _dbHelper.database;
    final rs = await db.rawQuery('''
    SELECT SUM(kl.${KyLuongTable.tongLuong}) AS tong_luong
    FROM ${KyLuongTable.tableName} kl
    JOIN ${PhienChotCongTable.tableName} pc  ON kl.${KyLuongTable.idPhienChot} = pc.${PhienChotCongTable.id}
    WHERE kl.${KyLuongTable.idNhanVienCongTrinh} = ?  AND pc.${PhienChotCongTable.idChamCong} = ? AND kl.${KyLuongTable.is_deleted} = 0
  ''', [idNhanVienCongTrinh, idBangChamCong]);
    if (rs.isNotEmpty && rs.first['tong_luong'] != null) {
      return (rs.first['tong_luong'] as num).toDouble();
    }
    return 0.0;
  }
  /**********************************ỨNG LƯƠNG***************************************/
  // Tính tổng số tiền ứng còn lại, k tính số tiền đã trừ trong bảng lương hiện tại
  // Tính tổng số tiền đã ứng
  // Tính tổng số tiền đã khấu trừ, ngoại trừ bảng lương hiện tại

  Future<double> tongTienUngLuongForNhanVien({ required int idNhanVienCongTrinh, int? idBangChamCong, }) async {
    final db = await _dbHelper.database;
    // 1. Tính tổng tất cả tiền nhân viên đã ứng (chưa bị xóa)
    final resDaUng = await db.rawQuery('''
    SELECT SUM(${UngLuongTable.soTien}) AS total
    FROM ${UngLuongTable.tableName}
    WHERE ${UngLuongTable.idNhanVienCongTrinh} = ?
      AND ${UngLuongTable.is_deleted} = 0
  ''', [idNhanVienCongTrinh]);

    // 2. Tính tổng tiền đã đối trừ ở các bảng lương KHÁC (không tính bảng lương hiện tại idBangLuong)
    // Kết nối (JOIN) với UngLuongTable để đảm bảo đúng idNhanVienCongTrinh
    final resDaTruCacKyKhac = await db.rawQuery('''
    SELECT SUM(ct.${ChiTietDoiTruUngLuongTable.soTienDoiTru}) AS total
    FROM ${ChiTietDoiTruUngLuongTable.tableName} ct
    INNER JOIN ${UngLuongTable.tableName} ul 
      ON ct.${ChiTietDoiTruUngLuongTable.idUngLuong} = ul.${UngLuongTable.id}
    INNER JOIN ${KyLuongTable.tableName} kl on ${ChiTietDoiTruUngLuongTable.idBangLuong} = ${KyLuongTable.id}
    INNER JOIN ${PhienChotCongTable.tableName} pc on ${KyLuongTable.idPhienChot} = ${PhienChotCongTable.id}
    WHERE ul.${UngLuongTable.idNhanVienCongTrinh} = ?
      AND ct.${ChiTietDoiTruUngLuongTable.isDeleted} = 0
      AND ul.${UngLuongTable.is_deleted} = 0
      'AND pc.${PhienChotCongTable.idChamCong} != ?' : ''}
  ''',[idNhanVienCongTrinh, idBangChamCong]);

    // Lấy giá trị num từ kết quả query (mặc định 0.0 nếu null)
    final double tongUng = (resDaUng.first['total'] as num?)?.toDouble() ?? 0.0;
    final double tongDaTruKhac = (resDaTruCacKyKhac.first['total'] as num?)?.toDouble() ?? 0.0;

    // Số tiền ứng chưa bị trừ (hoặc chưa bị trừ ở các kỳ trước)
    return tongUng - tongDaTruKhac;
  }
}