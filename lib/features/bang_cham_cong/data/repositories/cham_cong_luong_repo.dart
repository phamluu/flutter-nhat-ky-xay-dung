import 'package:nhat_ky_xay_dung/core/utils/trang_thai_khoa_cong.dart';
import 'package:nhat_ky_xay_dung/core/utils/trang_thai_luong.dart';
import 'package:nhat_ky_xay_dung/data/tables/cham_cong_chi_tiet_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/cham_cong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/chi_luong_table.dart';
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
  Future<void> DeleteData(int? idBangChamCong) async {
    final db = await _dbHelper.database;
    // Kiểm tra bảng chấm công đang khóa => không được xóa
    // Kiểm tra tồn tại kỳ lương đã chốt => không được xóa
    final results = await Future.wait([
      db.query(PhienChotCongTable.tableName,
          columns: [PhienChotCongTable.id],
          where:
              '${PhienChotCongTable.idChamCong} = ?',
          whereArgs: [idBangChamCong],
          limit: 1)
    ]);
    if (results[0].isNotEmpty) {
      throw Exception('Bảng chấm đã khóa. Hãy mở khóa chấm công trước');
    }
    try {
      await db.delete(ChamCongChiTietTable.tableName,
          where: '${ChamCongChiTietTable.idChamCong} = ?',
          whereArgs: [idBangChamCong]);
    } catch (e) {
      throw Exception('Lỗi: Không thể xóa');
    }
  }

  Future<void> setKhoaChamCong(
    int? idBangChamCong,
    DateTime? dateSelected,
    Set<int>? selectedNhanVienIds,
  ) async {
    if (idBangChamCong == null ||
        dateSelected == null ||
        selectedNhanVienIds == null ||
        selectedNhanVienIds.isEmpty) {
      throw Exception('Thông tin chốt công không hợp lệ');
    }

    // 1. Chuẩn hóa ngày về chuỗi YYYY-MM-DD ngắn để so sánh chính xác tuyệt đối
    final year = dateSelected.year;
    final monthStr = dateSelected.month.toString().padLeft(2, '0');
    final dayStr = dateSelected.day.toString().padLeft(2, '0');
    final dateSelectedFormatted = '$year-$monthStr-$dayStr'; // vd: "2026-09-15"

    final db = await _dbHelper.database;

    // 2. Sửa lỗi IN (?): Giải nén selectedNhanVienIds thành các tham số riêng biệt
    final placeholders = List.filled(selectedNhanVienIds.length, '?').join(',');
    final phienChotCong = await db.rawQuery('''
    SELECT 1 FROM ${ChamCongChiTietTable.tableName} ct 
    INNER JOIN ${PhienChotCongTable.tableName} pc ON ct.${ChamCongChiTietTable.idPhienChot} = pc.${PhienChotCongTable.id}
    WHERE pc.${PhienChotCongTable.idChamCong} = ? 
      AND date(pc.${PhienChotCongTable.denNgay}) = date(?) 
      AND ct.${ChamCongChiTietTable.idNhanVienCongTrinh} IN ($placeholders)
  ''', [idBangChamCong, dateSelectedFormatted, ...selectedNhanVienIds]);

    if (phienChotCong.isNotEmpty) {
      throw Exception('Đã tồn tại phiên chốt công cho ngày này');
    }

    try {
      await db.transaction((txn) async {
        // 3. Tính số đợt chốt
        final dotChotList = await txn.query(
          PhienChotCongTable.tableName,
          columns: [PhienChotCongTable.id],
          where: '${PhienChotCongTable.idChamCong} = ?',
          whereArgs: [idBangChamCong],
        );
        int dotChotIndex = dotChotList.length + 1;

        final phienChot = PhienChotCong(
          idChamCong: idBangChamCong,
          maDot: dotChotIndex.toString(),
          denNgay: dateSelectedFormatted,
        );

        final idPhienChot = await txn.insert(
          PhienChotCongTable.tableName,
          phienChot.toMapInsert(),
        );

        // 4. Lấy TẤT CẢ bản ghi ngày đã có của danh sách NV trong 1 query duy nhất (Tối ưu hiệu năng)
        final existingRecords = await txn.rawQuery('''
        SELECT ${ChamCongChiTietTable.idNhanVienCongTrinh}, ${ChamCongChiTietTable.ngay}
        FROM ${ChamCongChiTietTable.tableName}
        WHERE ${ChamCongChiTietTable.idNhanVienCongTrinh} IN ($placeholders)
          AND date(${ChamCongChiTietTable.ngay}) <= date(?)
      ''', [...selectedNhanVienIds, dateSelectedFormatted]);

        // Gom nhóm ngày đã có theo ID nhân viên: Map<idNV, Set<YYYY-MM-DD>>
        final Map<int, Set<String>> nvExistingDatesMap = {};
        for (final row in existingRecords) {
          final idNV = row[ChamCongChiTietTable.idNhanVienCongTrinh] as int;
          final rawDate = row[ChamCongChiTietTable.ngay] as String;

          final parsedDate = DateTime.parse(rawDate).toLocal();
          final formattedDate =
              "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";

          nvExistingDatesMap.putIfAbsent(idNV, () => {}).add(formattedDate);
        }

        // 5. Khởi tạo Batch duy nhất cho toàn bộ quá trình
        final batch = txn.batch();

        for (final idNV in selectedNhanVienIds) {
          // Update các ngày ĐÃ CÓ trong DB
          batch.update(
            ChamCongChiTietTable.tableName,
            {
              ChamCongChiTietTable.idPhienChot: idPhienChot,
            },
            where: '${ChamCongChiTietTable.idPhienChot} IS NULL '
                'AND date(substr(${ChamCongChiTietTable.ngay}, 1, 10)) <= date(?) '
                'AND ${ChamCongChiTietTable.idNhanVienCongTrinh} = ?',
            whereArgs: [dateSelectedFormatted, idNV],
          );

          final existingDates = nvExistingDatesMap[idNV] ?? {};

          // Duyệt từ ngày 1 tới ngày chốt để chèn ngày CHƯA CÓ
          for (int day = 1; day <= dateSelected.day; day++) {
            final currentDateStr =
                "$year-$monthStr-${day.toString().padLeft(2, '0')}";

            if (!existingDates.contains(currentDateStr)) {
              batch.insert(
                ChamCongChiTietTable.tableName,
                {
                  ChamCongChiTietTable.idNhanVienCongTrinh: idNV,
                  ChamCongChiTietTable.ngay: currentDateStr,
                  ChamCongChiTietTable.idChamCong: idBangChamCong,
                  ChamCongChiTietTable.trangThaiSang:
                      TrangThaiChamCong.khongXacDinh.value,
                  ChamCongChiTietTable.trangThaiChieu:
                      TrangThaiChamCong.khongXacDinh.value,
                  ChamCongChiTietTable.idPhienChot: idPhienChot,
                },
              );
            }
          }
        }

        // Commit toàn bộ câu lệnh
        await batch.commit(noResult: true);
      });
    } catch (e) {
      rethrow; // Dùng rethrow để giữ nguyên StackTrace thay vì throw Exception(e)
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
    try {
      await db.transaction((txn) async {
        // Kiểm tra nếu đã chốt lương thì k thể hủy khóa chấm công
        // Trường hợp không còn idphien nào thì xóa chốt lương
        final chot = await txn.query(ChamCongChiTietTable.tableName,
            columns: [ChamCongChiTietTable.id],
            where: '${ChamCongChiTietTable.idPhienChot} = ?',
            whereArgs: [idPhienChot]);
        if(chot.isEmpty){
          final kyLuong = await txn.query(KyLuongTable.tableName,
              columns: [KyLuongTable.id],
              where: '${KyLuongTable.idPhienChot} = ?',
              whereArgs: [idPhienChot]);
          if (kyLuong.isNotEmpty) {
            final listIdKyLuong = kyLuong.map((row) => row[KyLuongTable.id] as int).toList();
            // 2. Tạo chuỗi placeholders (?, ?, ?)
            final placeholders = List.filled(listIdKyLuong.length, '?').join(',');
            // 3. Xóa các khoản Chi Lương liên quan (nếu cần)
            await txn.delete(
              ChiLuongTable.tableName,
              where: '${ChiLuongTable.idBangLuong} IN ($placeholders)',
              whereArgs: listIdKyLuong,
            );
            final truLuong = await txn.delete(ChiTietDoiTruUngLuongTable.tableName,
            where: '${ChiTietDoiTruUngLuongTable.idBangLuong} IN ($placeholders)',
              whereArgs: listIdKyLuong,);
          }
          await txn.delete(
            KyLuongTable.tableName,
            where: '${KyLuongTable.idPhienChot} = ?',
            whereArgs: [idPhienChot],
          );
        }else{
          final kyLuong = await txn.query(KyLuongTable.tableName,
              columns: [KyLuongTable.id],
              where: '${KyLuongTable.idPhienChot} = ?',
              whereArgs: [idPhienChot]);
          if(kyLuong.isNotEmpty){
            throw Exception('Đã có dữ liệu chốt lương');
          }
          await txn.update(
            ChamCongChiTietTable.tableName, // Tên bảng chấm công của bạn
            {
              ChamCongChiTietTable.idPhienChot: null,
            },
            where: '${ChamCongChiTietTable.idPhienChot} = ?',
            whereArgs: [idPhienChot],
          );
        }
        await txn.delete(
          PhienChotCongTable.tableName,
          where: '${PhienChotCongTable.id} = ?',
          whereArgs: [idPhienChot],
        );
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<ChamCongLuongNhanVien>> chamCongNhanViens({int? idCongTrinh,int? idBangChamCong,}) async {
    final db = await _dbHelper.database;
    // 1. Lấy danh sách ID (bỏ limit: 1 nếu muốn lấy tất cả nhân viên)
    final rows = await db.query(
      NhanVienCongTrinhTable.tableName,
      columns: [NhanVienCongTrinhTable.id],
      where: '${NhanVienCongTrinhTable.idCongTrinh} = ?',
      whereArgs: [idCongTrinh],
    );
    if (rows.isNotEmpty) {
      // 2. Chuyển đổi danh sách Map thành Set<int>
      final Set<int> selectIdNhanVienCongTrinh = rows
          .map((row) => row[NhanVienCongTrinhTable.id] as int)
          .toSet();
      // 3. Await và return kết quả
      return await loadChamCongs(
        selectIdNhanVienCongTrinh: selectIdNhanVienCongTrinh,
        idBangChamCong: idBangChamCong,
      );
    }
    // 4. Trả về danh sách rỗng nếu không có dữ liệu
    return [];
  }
  Future<List<ChamCongLuongNhanVien>> loadChamCongs({int? idPhien, Set<int>? selectIdNhanVienCongTrinh, int? idBangChamCong,}) async {
    final db = await _dbHelper.database;
    final Map<int, ChamCongLuongNhanVien> resultMap = {};

    // =========================================================================
    // BƯỚC 1: Lấy danh sách Nhân viên công trình theo danh sách ID truyền vào
    // (Đảm bảo 100% nhân viên yêu cầu đều xuất hiện trong resultMap)
    // =========================================================================
    final List<String> nvWhereConditions = [];
    final List<dynamic> nvWhereArgs = [];

    if (selectIdNhanVienCongTrinh != null && selectIdNhanVienCongTrinh.isNotEmpty) {
      final placeholders = List.filled(selectIdNhanVienCongTrinh.length, '?').join(',');
      nvWhereConditions.add('nvct.${NhanVienCongTrinhTable.id} IN ($placeholders)');
      nvWhereArgs.addAll(selectIdNhanVienCongTrinh);
    }

    final String nvWhereClause = nvWhereConditions.isNotEmpty ? 'WHERE ${nvWhereConditions.join(' AND ')}' : '';

    final listNhanVien = await db.rawQuery('''
    SELECT 
      nvct.${NhanVienCongTrinhTable.id} AS idNhanVienCongTrinh,
      nvct.${NhanVienCongTrinhTable.vaiTro},
      nv.${NhanVienTable.id} AS idNhanVien,
      nv.${NhanVienTable.hoTen},
      nv.${NhanVienTable.soDienThoai}
    FROM ${NhanVienCongTrinhTable.tableName} nvct
    INNER JOIN ${NhanVienTable.tableName} nv 
      ON nvct.${NhanVienCongTrinhTable.idNhanVien} = nv.${NhanVienTable.id}
    $nvWhereClause
    ORDER BY nvct.${NhanVienCongTrinhTable.id} ASC
  ''', nvWhereArgs);

    if (listNhanVien.isEmpty) return [];

    // Khởi tạo thông tin mặc định cho từng nhân viên
    for (final rowNv in listNhanVien) {
      final idNvct = rowNv['idNhanVienCongTrinh'] as int;

      double tongUngDuKienCongLai = 0;
      double daTruKyNay = 0;

      if (idPhien != null) {
        final (_, _tongUngDuKienCongLai, _daTruKyNay) =
        await _ungLuongRepo.tongUngForPhienChot(idPhien, idNvct);
        tongUngDuKienCongLai = _tongUngDuKienCongLai;
        daTruKyNay = _daTruKyNay;
      } else if (idBangChamCong != null) {
        final (_, _tongUngDuKienCongLai, _daTruKyNay) =
        await _ungLuongRepo.tongUngForChamCong(idBangChamCong, idNvct);
        tongUngDuKienCongLai = _tongUngDuKienCongLai;
        daTruKyNay = _daTruKyNay;
      }

      // Lấy thông tin lương chốt
      final luongList = await db.rawQuery('''
      SELECT COUNT(l.${KyLuongTable.id}) as countRecord,
             SUM(COALESCE(${KyLuongTable.tongLuong}, 0)) as tongLuong,
             SUM(COALESCE(${KyLuongTable.tongUng}, 0)) as tongUng,
             SUM(COALESCE(${KyLuongTable.tongCong}, 0)) as tongSoCong,
             SUM(COALESCE(${KyLuongTable.thucNhan}, 0)) as thucNhan
      FROM ${PhienChotCongTable.tableName} pc
      INNER JOIN ${KyLuongTable.tableName} l ON pc.${PhienChotCongTable.id} = l.${KyLuongTable.idPhienChot}
      WHERE ((? IS NOT NULL AND pc.${PhienChotCongTable.idChamCong} = ?)
        OR (? IS NOT NULL AND l.${KyLuongTable.idPhienChot} = ?))
        AND l.${KyLuongTable.trangThai} = ?
        AND l.${KyLuongTable.idNhanVienCongTrinh} = ?
    ''', [
        idBangChamCong,
        idBangChamCong,
        idPhien,
        idPhien,
        TrangThaiLuong.dachot.value,
        idNvct,
      ]);

      double? tongLuongChot;
      double? tongUngChot;
      double? thucNhanChot;
      int? trangThaiLuongChot = TrangThaiLuong.chuachot.value;
      int? countRecord = (luongList.first['countRecord'] as num?)?.toInt();

      if (luongList.isNotEmpty && (countRecord ?? 0) > 0) {
        tongLuongChot = (luongList.first['tongLuong'] as num?)?.toDouble();
        tongUngChot = (luongList.first['tongUng'] as num?)?.toDouble();
        thucNhanChot = (luongList.first['thucNhan'] as num?)?.toDouble();
        trangThaiLuongChot = TrangThaiLuong.dachot.value;
      }

      double? _tongDaChi;
      bool _daChiLuong = false;

      final daChiRow = await db.rawQuery('''
      SELECT COALESCE(SUM(cl.${ChiLuongTable.soTien}), 0) as total
      FROM ${ChiLuongTable.tableName} cl
      INNER JOIN ${KyLuongTable.tableName} kl ON cl.${ChiLuongTable.idBangLuong} = kl.${KyLuongTable.id}
      INNER JOIN ${PhienChotCongTable.tableName} pc ON kl.${KyLuongTable.idPhienChot} = pc.${PhienChotCongTable.id}
      WHERE kl.${KyLuongTable.idNhanVienCongTrinh} = ? 
        AND (
          (? IS NOT NULL AND kl.${KyLuongTable.idPhienChot} = ?)
          OR 
          (? IS NOT NULL AND pc.${PhienChotCongTable.idChamCong} = ?)
        )
    ''', [idNvct, idPhien, idPhien, idBangChamCong, idBangChamCong]);

      if (daChiRow.isNotEmpty) {
        _tongDaChi = (daChiRow.first['total'] as num?)?.toDouble() ?? 0.0;
        _daChiLuong = true;
      }

      resultMap[idNvct] = ChamCongLuongNhanVien(
        idNhanVienCongTrinh: idNvct,
        hoTen: rowNv[NhanVienTable.hoTen] as String?,
        soDienThoai: rowNv[NhanVienTable.soDienThoai] as String?,
        chucVu: rowNv[NhanVienCongTrinhTable.vaiTro] as String?,
        data: {}, // Khởi tạo Map dữ liệu ngày rỗng
        tongUngDuKien: tongUngDuKienCongLai,
        tongUngDaTru: daTruKyNay,
        tongLuongChot: tongLuongChot,
        tongUngChot: tongUngChot,
        trangThaiLuong: trangThaiLuongChot,
        trangThaiChiLuong: _daChiLuong,
        thucNhanChot: thucNhanChot,
        tongDaChi: _tongDaChi,
      );
    }

    // =========================================================================
    // BƯỚC 2: Đọc dữ liệu chấm công chi tiết & đắp vào resultMap
    // =========================================================================
    final List<String> ccConditions = [];
    final List<dynamic> ccWhereArgs = [];

    if (idPhien != null) {
      ccConditions.add('cc.${ChamCongChiTietTable.idPhienChot} = ?');
      ccWhereArgs.add(idPhien);
    }

    if (selectIdNhanVienCongTrinh != null && selectIdNhanVienCongTrinh.isNotEmpty) {
      final placeholders = List.filled(selectIdNhanVienCongTrinh.length, '?').join(',');
      ccConditions.add('cc.${ChamCongChiTietTable.idNhanVienCongTrinh} IN ($placeholders)');
      ccWhereArgs.addAll(selectIdNhanVienCongTrinh);
    }

    if (idBangChamCong != null) {
      ccConditions.add('cc.${ChamCongChiTietTable.idChamCong} = ?');
      ccWhereArgs.add(idBangChamCong);
    }

    final String ccWhereClause = ccConditions.isNotEmpty ? 'WHERE ${ccConditions.join(' AND ')}' : '';

    final ccResults = await db.rawQuery('''
    SELECT 
      cc.${ChamCongChiTietTable.id} AS idChamCongChiTiet,
      cc.${ChamCongChiTietTable.idNhanVienCongTrinh},
      cc.${ChamCongChiTietTable.ngay},
      cc.${ChamCongChiTietTable.trangThaiSang},
      cc.${ChamCongChiTietTable.trangThaiChieu},
      cc.${ChamCongChiTietTable.ghiChu},
      cc.${ChamCongChiTietTable.idPhienChot},
      (
        SELECT lcb.${LuongCoBanTable.mucLuong}
        FROM ${LuongCoBanTable.tableName} lcb
        INNER JOIN ${NhanVienCongTrinhTable.tableName} nvct_sub 
          ON lcb.${LuongCoBanTable.idNhanVien} = nvct_sub.${NhanVienCongTrinhTable.idNhanVien}
        WHERE nvct_sub.${NhanVienCongTrinhTable.id} = cc.${ChamCongChiTietTable.idNhanVienCongTrinh}
          AND (lcb.${LuongCoBanTable.ngayApDung} IS NULL OR date(lcb.${LuongCoBanTable.ngayApDung}) <= date(cc.${ChamCongChiTietTable.ngay}))
        ORDER BY lcb.${LuongCoBanTable.ngayApDung} DESC
        LIMIT 1
      ) AS luongNgay
    FROM ${ChamCongChiTietTable.tableName} cc
    $ccWhereClause
    ORDER BY cc.${ChamCongChiTietTable.idNhanVienCongTrinh} ASC, cc.${ChamCongChiTietTable.ngay} ASC
  ''', ccWhereArgs);

    // Đổ dữ liệu chấm công chi tiết vào nhân viên tương ứng
    for (final row in ccResults) {
      final idNvct = row[ChamCongChiTietTable.idNhanVienCongTrinh] as int;

      // Kiểm tra nhân viên có trong resultMap không trước khi đắp dữ liệu
      if (resultMap.containsKey(idNvct)) {
        final rawNgay = row[ChamCongChiTietTable.ngay] as String;
        final normalizedNgay = rawNgay.contains('T') ? rawNgay.substring(0, 10) : rawNgay;

        final sang = TrangThaiChamCong.fromValue(row[ChamCongChiTietTable.trangThaiSang] as int?);
        final chieu = TrangThaiChamCong.fromValue(row[ChamCongChiTietTable.trangThaiChieu] as int?);
        final luongNgay = (row['luongNgay'] as num?)?.toDouble() ?? 0.0;

        final chamCong = ChamCongNgay(
          id: row['idChamCongChiTiet'] as int?,
          sang: sang,
          chieu: chieu,
          ghiChu: (row[ChamCongChiTietTable.ghiChu] ?? '').toString(),
          idPhienChot: row[ChamCongChiTietTable.idPhienChot] as int?,
        );

        resultMap[idNvct]!.data[normalizedNgay] = ChamCongNgayLuong(
          chamCong: chamCong,
          luongNgay: luongNgay,
        );
      }
    }

    return resultMap.values.toList();
  }
  /// Lấy danh sách chấm công và tổng lương của từng nhân viên theo đợt chốt công
  Future<List<ChamCongLuongNhanVien>> chamCongNhanVienPhienChot({int? idPhien}) async {
    final db = await _dbHelper.database;
    // 1. Thực hiện Query lấy danh sách Map từ SQLite
    final List<Map<String, dynamic>> results = await db.query(
      ChamCongChiTietTable.tableName,
      columns: [ChamCongChiTietTable.idNhanVienCongTrinh],
      where: '${ChamCongChiTietTable.idPhienChot} = ?',
      whereArgs: [idPhien],
      distinct: true, // Lọc trùng lặp ngay từ câu SQL (Tùy chọn)
    );
    if(results.isNotEmpty){
      // 2. Chuyển đổi List<Map> thành Set<int>
      final Set<int> selectIdNhanVienCongTrinh = results
          .map((row) => row[ChamCongChiTietTable.idNhanVienCongTrinh] as int)
          .toSet();
      return await loadChamCongs(
        selectIdNhanVienCongTrinh: selectIdNhanVienCongTrinh,
        idPhien: idPhien,
      );
    }
    return [];
  }
  /*********************************LƯƠNG******************************************/

  Future<void> chotLuongTheoDanhSach({ required Set<int> danhSachDuocChon, required int idPhienChot,}) async {
    if (danhSachDuocChon.isEmpty) return;
    // Lấy dữ liệu xong hoàn toàn trước khi gọi Transaction
    final models = await loadChamCongs(
      idPhien: idPhienChot,
      selectIdNhanVienCongTrinh: danhSachDuocChon,
    );
    if (models.isEmpty) return;
    final tonTaiChiLuong = models.any((nv) => (nv.tongDaChi ?? 0) > 0);
    if (tonTaiChiLuong) {
      throw Exception('Trong danh sách đã chọn có nhân viên đã được chi lương!');
    }
    final db = await _dbHelper.database;
    // Mở Transaction ghi dữ liệu
    await db.transaction((txn) async {
      for (var nv in models) {
        if (nv.idNhanVienCongTrinh == null) continue;
        final double thucNhan = nv.tongLuongDuKien - nv.tongUngDuKien;
        final int idNVCT = nv.idNhanVienCongTrinh!;
        final Map<String, dynamic> values = {
          KyLuongTable.idNhanVienCongTrinh: idNVCT,
          KyLuongTable.idPhienChot: idPhienChot,
          KyLuongTable.tongCong: nv.soCong,
          KyLuongTable.tongLuong: nv.tongLuongDuKien,
          KyLuongTable.tongUng: nv.tongUngDuKien,
          KyLuongTable.thucNhan: thucNhan,
          KyLuongTable.trangThai: TrangThaiLuong.dachot.value,
          KyLuongTable.ngayChot: DateTime.now().toIso8601String(),
        };
        // 1. Tìm bản ghi kỳ lương qua txn
        final existingRecord = await txn.query(
          KyLuongTable.tableName,
          columns: [KyLuongTable.id],
          where:
              '${KyLuongTable.idPhienChot} = ? AND ${KyLuongTable.idNhanVienCongTrinh} = ?',
          whereArgs: [idPhienChot, idNVCT],
          limit: 1,
        );
        int idKyLuong;
        if (existingRecord.isNotEmpty) {
          idKyLuong = existingRecord.first[KyLuongTable.id] as int;
          await txn.update(
            KyLuongTable.tableName,
            values,
            where: '${KyLuongTable.id} = ?',
            whereArgs: [idKyLuong],
          );
        } else {
          idKyLuong = await txn.insert(
            KyLuongTable.tableName,
            values,
          );
        }

        // 2. Query danh sách ứng lương qua txn
        final listUngLuong = await txn.rawQuery('''
        SELECT *
        FROM ${UngLuongTable.tableName}
        WHERE ${UngLuongTable.idNhanVienCongTrinh} = ?
          AND ${UngLuongTable.is_deleted} = 0
        ORDER BY ${UngLuongTable.ngayUng} ASC
      ''', [idNVCT]);

        // 3. Thực hiện khấu trừ tiền ứng (chạy hoàn toàn trên txn)
        await _chotRepo.chotDoiTruLuong(
          listUngLuong,
          nv.tongLuongDuKien,
          idNVCT,
          idKyLuong,
          executor: txn,
        );
      }
    });
  }

  Future<void> huyChotLuongTheoDanhSach({required Set<int> danhSachDuocChon, required int idPhienChot}) async {
    final db = await _dbHelper.database;
    if (danhSachDuocChon.isEmpty) return;
    final nhanVienPlaceholders = List.filled(danhSachDuocChon.length, '?').join(',');
    // 1. Lấy ID kỳ lương của những nhân viên được chọn
    final rows = await db.query(
      KyLuongTable.tableName,
      columns: [KyLuongTable.id],
      where: '${KyLuongTable.idNhanVienCongTrinh} IN ($nhanVienPlaceholders) '
          'AND ${KyLuongTable.idPhienChot} = ?',
      whereArgs: [
        ...danhSachDuocChon,
        idPhienChot,
      ],
    );
    final bangLuongs = rows
        .map((row) => row[KyLuongTable.id])
        .whereType<int>()
        .toList();
    if (bangLuongs.isEmpty) return;
    final bangLuongPlaceholders = List.filled(bangLuongs.length, '?').join(',');
    final tonTaiChiLuong = await db.query(
      ChiLuongTable.tableName,
      columns: [ChiLuongTable.id],
      where: '${ChiLuongTable.idBangLuong} IN ($bangLuongPlaceholders)',
      whereArgs: bangLuongs,
      limit: 1,
    );
    if (tonTaiChiLuong.isNotEmpty) {
      throw Exception('Tồn tại nhân viên đã chi lương');
    }
    // 2. Xóa đối ứng trừ lương
    if (bangLuongs.isNotEmpty) {
      final bangLuongPlaceholders =
          List.filled(bangLuongs.length, '?').join(',');
      await db.delete(
        ChiTietDoiTruUngLuongTable.tableName,
        where: '${ChiTietDoiTruUngLuongTable.idBangLuong} '
            'IN ($bangLuongPlaceholders)',
        whereArgs: bangLuongs,
      );
    }
    // 3. Xóa kỳ lương
    await db.delete(
      KyLuongTable.tableName,
      where: '${KyLuongTable.idNhanVienCongTrinh} IN ($nhanVienPlaceholders) '
          'AND ${KyLuongTable.idPhienChot} = ?',
      whereArgs: [
        ...danhSachDuocChon,
        idPhienChot,
      ],
    );
  }

  Future<double> tongLuongChotForNhanVien({int? idNhanVienCongTrinh, int? idBangChamCong,}) async {
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
  Future<double> tongTienUngLuongForNhanVien({ required int idNhanVienCongTrinh, int? idBangChamCong,}) async {
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
  ''', [idNhanVienCongTrinh, idBangChamCong]);

    // Lấy giá trị num từ kết quả query (mặc định 0.0 nếu null)
    final double tongUng = (resDaUng.first['total'] as num?)?.toDouble() ?? 0.0;
    final double tongDaTruKhac =
        (resDaTruCacKyKhac.first['total'] as num?)?.toDouble() ?? 0.0;

    // Số tiền ứng chưa bị trừ (hoặc chưa bị trừ ở các kỳ trước)
    return tongUng - tongDaTruKhac;
  }

  /******************************CHI LƯƠNG**********************************/
  // tổng chi của 1 kỳ lương không được vượt quá con số thực nhận
  Future<void> setChiLuong( Set<int> selectedIds, int? idPhienChot, DateTime? ngayChi) async {
    if (selectedIds.isEmpty) return;
    final models = await loadChamCongs(
      idPhien: idPhienChot,
      selectIdNhanVienCongTrinh: selectedIds,
    );
    if (models.isEmpty) return;
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      for (var nv in models) {
        if (nv.idNhanVienCongTrinh == null) continue;
        final bangLuong = await txn.query(KyLuongTable.tableName,
            where:
                '${KyLuongTable.idPhienChot} = ? AND ${KyLuongTable.idNhanVienCongTrinh} = ?'
                'AND ${KyLuongTable.trangThai} = ?',
            whereArgs: [
              idPhienChot,
              nv.idNhanVienCongTrinh,
              TrangThaiLuong.dachot.value
            ],
            limit: 1);
        if (bangLuong.isEmpty) {
          throw Exception('Tồn tại nhân viên chưa chốt lương');
        }
        final daChi = await txn.rawQuery('''
        SELECT cl.* FROM ${ChiLuongTable.tableName} cl 
              INNER JOIN ${KyLuongTable.tableName} kl on cl.${ChiLuongTable.idBangLuong} = kl.${KyLuongTable.id}
              WHERE kl.${KyLuongTable.idNhanVienCongTrinh} = ? AND kl.${KyLuongTable.idPhienChot} = ?
        ''',[nv.idNhanVienCongTrinh, idPhienChot]);
        if (daChi.isNotEmpty) {
          throw Exception('Tồn tại nhân viên đã chi lương');
        }
        final today = DateTime.now().toIso8601String();
        final Map<String, dynamic> values = {
          ChiLuongTable.idBangLuong: bangLuong.first[KyLuongTable.id] as int,
          ChiLuongTable.soTien: nv.thucNhanChot,
          ChiLuongTable.ngayChi: ngayChi?.toIso8601String(),
          ChiLuongTable.ghiChu: 'Chi lương chung theo đợt',
          ChiLuongTable.createdAt: today
        };
        await txn.insert(ChiLuongTable.tableName, values);
      }
    });
  }
  Future<void> setHuyChiLuong(Set<int> selectedIds, int? idPhienChot) async {
    if (selectedIds.isEmpty || idPhienChot == null) return;

    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // 1. Tạo danh sách dấu ? tương ứng với selectedIds
      final placeholders = List.filled(selectedIds.length, '?').join(',');

      final kyLuongRows = await txn.query(
        KyLuongTable.tableName,
        columns: [KyLuongTable.id],
        where: '${KyLuongTable.idPhienChot} = ? AND ${KyLuongTable.idNhanVienCongTrinh} IN ($placeholders)',
        whereArgs: [idPhienChot, ...selectedIds],
      );

      if (kyLuongRows.isEmpty) return;

      // 2. Trích xuất danh sách ID thực tế từ kết quả query
      final idKyLuongList = kyLuongRows
          .map((row) => row[KyLuongTable.id])
          .where((id) => id != null)
          .toList();

      if (idKyLuongList.isEmpty) return;

      // 3. Tạo chuỗi dấu ? cho câu lệnh DELETE dựa trên số lượng ID thu được
      final deletePlaceholders = List.filled(idKyLuongList.length, '?').join(',');

      // 4. Thực thi xóa với chuỗi $deletePlaceholders và danh sách ID thực tế
      await txn.delete(
        ChiLuongTable.tableName,
        where: '${ChiLuongTable.idBangLuong} IN ($deletePlaceholders)',
        whereArgs: idKyLuongList, // Truyền trực tiếp List chứa các giá trị ID
      );
    });
  }
}
