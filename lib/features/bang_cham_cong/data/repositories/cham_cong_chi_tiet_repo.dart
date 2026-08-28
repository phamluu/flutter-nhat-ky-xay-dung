import 'package:nhat_ky_xay_dung/data/tables/cham_cong_chi_tiet_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/luong_co_ban_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_cong_trinh_table.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/models/cham_cong_chi_tiet.dart';

import '../../../../core/utils/trang_thai_cham_cong.dart';
import '../../../../data/db_helper.dart';
import '../../../../data/tables/cham_cong_table.dart';
import '../../../luong/data/models/LuongCoBan.dart';
import '../models/ChamCongModel.dart';

class ChamCongChiTietRepo {
  final _dbHelper = DBHelper.instance;

  // Thêm chám công ngày
  Future<int> insert(ChamCongChiTiet chamCong) async {
    final db = await _dbHelper.database;
    return await db.insert(
        ChamCongChiTietTable.tableName, chamCong.toMapInsert());
  }

  // Cập nhật chấm công ngày
  Future<int> update(ChamCongChiTiet chamCong) async {
    final db = await _dbHelper.database;
    return await db.update(
      ChamCongChiTietTable.tableName,
      chamCong.toMapUpdate(),
      where: '${ChamCongChiTietTable.id} = ?',
      whereArgs: [chamCong.id],
    );
  }

  // Thêm hoặc cập nhật chấm công ngày
  Future<void> upsertChamCong(UpsertChamCongNgayParam param) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      final nowIso = DateTime.now().toIso8601String();
      // THƯỜNG TRƯỜNG HỢP 1: ĐÃ CÓ ID CHI TIẾT -> CẬP NHẬT TRỰC TIẾP
      if (param.idChamCongNgay != null) {
        final updatedRows = await txn.update(
          ChamCongChiTietTable.tableName,
          {
            ChamCongChiTietTable.trangThaiSang: param.trangThaiSang ?? 0,
            ChamCongChiTietTable.trangThaiChieu: param.trangThaiChieu ?? 0,
            ChamCongChiTietTable.ghiChu: param.ghiChu,
            ChamCongChiTietTable.updatedAt: nowIso,
            ChamCongChiTietTable.isSynced: 0,
          },
          where: '${ChamCongChiTietTable.id} = ?',
          whereArgs: [param.idChamCongNgay],
        );
        // Nếu update thành công thì kết thúc luôn, không cần check bảng cha
        if (updatedRows > 0) return;
      }

      // TRƯỜNG HỢP 2: CHƯA CÓ ID CHI TIẾT -> XỬ LÝ BẢNG CHẤM CÔNG (CHA)
      int? finalIdBangChamCong = param.idBangChamCong;

      // Nếu chưa truyền idBangChamCong -> Kiểm tra hoặc tạo mới bảng cha
      if (finalIdBangChamCong == null) {
        if (param.idCongTrinh == null) {
          throw Exception(
              "Cần idCongTrinh để xác định hoặc khởi tạo bảng chấm công.");
        }
        final thang = param.ngay.substring(0, 7); // 'yyyy-MM'
        final existBangCC = await txn.query(
          ChamCongTable.tableName,
          columns: [ChamCongTable.id],
          where:
              '${ChamCongTable.idCongTrinh} = ? AND ${ChamCongTable.thang} = ? AND ${ChamCongTable.isDeleted} = 0',
          whereArgs: [param.idCongTrinh, thang],
          limit: 1,
        );

        if (existBangCC.isNotEmpty) {
          finalIdBangChamCong = existBangCC.first[ChamCongTable.id] as int?;
        } else {
          finalIdBangChamCong = await txn.insert(
            ChamCongTable.tableName,
            {
              ChamCongTable.idCongTrinh: param.idCongTrinh,
              ChamCongTable.thang: thang,
              ChamCongTable.daKhoa: 0,
              ChamCongTable.ngayTao: nowIso,
              ChamCongTable.isSynced: 0,
              ChamCongTable.isDeleted: 0,
            },
          );
        }
      }

      // ------------------------------------------------------------
      // KIỂM TRA LẠI THEO UNIQUE CONSTRAINT TRƯỚC KHI THỰC HIỆN GHI
      // ------------------------------------------------------------
      final existing = await txn.query(
        ChamCongChiTietTable.tableName,
        columns: [ChamCongChiTietTable.id],
        where:
            '${ChamCongChiTietTable.idChamCong} = ? AND ${ChamCongChiTietTable.idNhanVienCongTrinh} = ? AND ${ChamCongChiTietTable.ngay} = ?',
        whereArgs: [finalIdBangChamCong, param.idNhanVienCongTrinh, param.ngay],
        limit: 1,
      );

      final dataChiTiet = <String, dynamic>{
        ChamCongChiTietTable.idChamCong: finalIdBangChamCong,
        ChamCongChiTietTable.idNhanVienCongTrinh: param.idNhanVienCongTrinh,
        ChamCongChiTietTable.ngay: param.ngay,
        ChamCongChiTietTable.trangThaiSang: param.trangThaiSang ?? 0,
        ChamCongChiTietTable.trangThaiChieu: param.trangThaiChieu ?? 0,
        ChamCongChiTietTable.ghiChu: param.ghiChu,
        ChamCongChiTietTable.updatedAt: nowIso,
        ChamCongChiTietTable.isSynced: 0,
      };

      if (existing.isNotEmpty) {
        final targetId = existing.first[ChamCongChiTietTable.id] as int;
        await txn.update(
          ChamCongChiTietTable.tableName,
          dataChiTiet,
          where: '${ChamCongChiTietTable.id} = ?',
          whereArgs: [targetId],
        );
      } else {
        dataChiTiet[ChamCongChiTietTable.isDeleted] = 0;
        await txn.insert(ChamCongChiTietTable.tableName, dataChiTiet);
      }
    });
  }

  // Load danh sách chấm công của toàn bản chấm công
  Future<List<ChamCongChiTiet>> chamCongs({int? idBangChamCong}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      ChamCongChiTietTable.tableName,
      where: idBangChamCong != null
          ? '${ChamCongChiTietTable.idChamCong} = ?'
          : null,
      whereArgs: idBangChamCong != null ? [idBangChamCong] : null,
      orderBy: '${ChamCongChiTietTable.id} DESC',
    );
    return maps.map((map) => ChamCongChiTiet.fromMap(map)).toList();
  }
  // lấy toàn bộ bảng chấm công đã chốt lương
  // lấy toàn bộ chấm công chi tiêt đã chốt lương => list idLuongCoBan dựa vào ngày & idNhanVienCongTrinh

  // Lấy lương cơ bản trong 1 ngày cụ thể của 1 nhân viên
  Future<Luongcoban> luongNgayForNhanVien({
    int? idNhanVien,
    int? idNhanVienCongTrinh,
    String? ngay,
  }) async {
    if (idNhanVien == null && idNhanVienCongTrinh == null) {
      throw Exception('Không xác định được nhân viên');
    }
    final db = await _dbHelper.database;
    final where = <String>[];
    final args = <dynamic>[];

    // Xác định nhân viên
    if (idNhanVien != null) {
      where.add(
        'lcb.${LuongCoBanTable.idNhanVien} = ?',
      );
      args.add(idNhanVien);
    } else {
      where.add(
        'nvct.${NhanVienCongTrinhTable.id} = ?',
      );
      args.add(idNhanVienCongTrinh);
    }

    // Chỉ lấy mức lương đã áp dụng đến ngày cần tính
    if (ngay != null && ngay.isNotEmpty) {
      where.add('''
      (
        lcb.${LuongCoBanTable.ngayApDung} IS NULL
        OR lcb.${LuongCoBanTable.ngayApDung} <= ?
      )
    ''');
      args.add(ngay);
    }
    final results = await db.rawQuery(
      '''
    SELECT
      lcb.${LuongCoBanTable.id} AS idLuongCoBan,
      lcb.${LuongCoBanTable.mucLuong} AS mucLuong,
      lcb.${LuongCoBanTable.ngayApDung} AS ngayApDung
    FROM ${LuongCoBanTable.tableName} lcb

    LEFT JOIN ${NhanVienCongTrinhTable.tableName} nvct
      ON nvct.${NhanVienCongTrinhTable.idNhanVien}
         = lcb.${LuongCoBanTable.idNhanVien}
    WHERE ${where.join(' AND ')}
    ORDER BY
      CASE
        WHEN lcb.${LuongCoBanTable.ngayApDung} IS NULL
        THEN 0
        ELSE 1
      END DESC,
      lcb.${LuongCoBanTable.ngayApDung} DESC
    LIMIT 1
    ''',
      args,
    );
    if (results.isEmpty) {
      return Luongcoban(mucLuong: 0);
    }
    final result = results.first;
    final idLuongCoBan = result['idLuongCoBan'] as int?;
    final mucLuong = (result['mucLuong'] as num?)?.toDouble() ?? 0.0;
    return Luongcoban(id: idLuongCoBan, mucLuong: mucLuong,);
  }
  // idChamCong là id trong table chấm công chi tiết
  // Load chấm công 1 ngày của 1 nhân viên
  Future<ChamCongNgayLuong?> getChamCongNgayLuongForNhanVien({int? idChamCong, int? idBangChamCong,
    int? idNhanVienCongTrinh, String? ngay}) async {
    if (idChamCong == null &&
        (idBangChamCong == null ||
            idNhanVienCongTrinh == null ||
            ngay == null)) {
      return null;
    }
    final db = await _dbHelper.database;
    final whereConditions = <String>[];
    final whereArgs = <dynamic>[];

    // Có idChamCong thì ưu tiên tìm chính xác theo ID
    if (idChamCong != null) {
      whereConditions.add('cc.${ChamCongChiTietTable.id} = ?',);
      whereArgs.add(idChamCong);
    } else {
      whereConditions.add( 'cc.${ChamCongChiTietTable.idChamCong} = ?',);
      whereArgs.add(idBangChamCong);
      whereConditions.add( 'cc.${ChamCongChiTietTable.idNhanVienCongTrinh} = ?',);
      whereArgs.add(idNhanVienCongTrinh);
      whereConditions.add( 'cc.${ChamCongChiTietTable.ngay} = ?',);
      whereArgs.add(ngay);
    }

    final results = await db.rawQuery('''
    SELECT 
      cc.${ChamCongChiTietTable.id},
      cc.${ChamCongChiTietTable.idNhanVienCongTrinh},
      cc.${ChamCongChiTietTable.ngay},
      cc.${ChamCongChiTietTable.trangThaiSang},
      cc.${ChamCongChiTietTable.trangThaiChieu},
      cc.${ChamCongChiTietTable.ghiChu},
      lcb.${LuongCoBanTable.mucLuong} AS luongNgay
    FROM ${ChamCongChiTietTable.tableName} cc
    JOIN ${NhanVienCongTrinhTable.tableName} nvct 
      ON nvct.${NhanVienCongTrinhTable.id} = cc.${ChamCongChiTietTable.idNhanVienCongTrinh}
    LEFT JOIN ${LuongCoBanTable.tableName} lcb 
      ON lcb.${LuongCoBanTable.idNhanVien} = nvct.${NhanVienCongTrinhTable.idNhanVien}
     AND (lcb.${LuongCoBanTable.ngayApDung} IS NULL OR lcb.${LuongCoBanTable.ngayApDung} <= cc.${ChamCongChiTietTable.ngay})
    WHERE ${whereConditions.join(' AND ')}
    ORDER BY lcb.${LuongCoBanTable.ngayApDung} DESC
    LIMIT 1
  ''', whereArgs);
    if (results.isEmpty) return null;
    final row = results.first;
    // 1. Tạo ChamCongNgay từ dòng dữ liệu
    final chamCong = ChamCongNgay(
      id: row[ChamCongChiTietTable.id] as int?,
      sang: TrangThaiChamCong.fromValue(
          row[ChamCongChiTietTable.trangThaiSang] as int?),
      chieu: TrangThaiChamCong.fromValue(
          row[ChamCongChiTietTable.trangThaiChieu] as int?),
      ghiChu: (row[ChamCongChiTietTable.ghiChu] ?? '').toString(),
    );
    // 2. Lấy mức lương ngày
    final luongNgay = (row['luongNgay'] as num?)?.toDouble() ?? 0.0;
    // 3. Trả về object gộp
    return ChamCongNgayLuong(
      chamCong: chamCong,
      luongNgay: luongNgay,
    );
  }
}
