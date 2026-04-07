import '../core/utils/trang_thai_cham_cong.dart';
import '../data/db_helper.dart';
import '../viewmodel/ChamCongModel.dart';

class ChamCongService {
  final _dbHelper = DBHelper.instance;
  Future<List<Map<String, dynamic>>> getChamCongThang(
      int idCongTrinh, int thang, int nam) async
  {
    final db = await _dbHelper.database;
    final firstDay = "$nam-${thang.toString().padLeft(2, '0')}-01";
    final lastDay = "$nam-${thang.toString().padLeft(2, '0')}-31";

    /// 👉 Query chấm công + lương theo ngày
    final chamCong = await db.rawQuery('''
        SELECT 
          nvct.id as id_nvct,
          nv.id as id_nv,
          nv.ho_ten,
          nvct.vaiTro,
          cc.ngay,
          cc.trang_thai_sang,
          cc.trang_thai_chieu,
          
          -- ✅ lương theo ngày áp dụng
        (
          SELECT lcb.mucLuong
          FROM luong_co_ban lcb
          WHERE lcb.idNhanVien = nv.id
            AND (lcb.ngayApDung IS NULL OR lcb.ngayApDung <= cc.ngay)
          ORDER BY lcb.ngayApDung DESC
          LIMIT 1
        ) as luongNgay
        FROM nhan_vien_cong_trinh nvct
        JOIN nhan_vien nv ON nv.id = nvct.idNhanVien
        LEFT JOIN cham_cong cc 
          ON cc.id_nhan_vien_cong_trinh = nvct.id
          AND cc.ngay BETWEEN ? AND ?
        WHERE nvct.idCongTrinh = ?
        ORDER BY nv.ho_ten
      ''', [firstDay, lastDay, idCongTrinh]);
    return chamCong;
  }

  // Load chấm công tháng
  Future<List<ChamCongModel>> loadChamCong(
      int idCongTrinh, int thang, int nam) async
  {
    final db = await _dbHelper.database;
    final raw = await getChamCongThang(idCongTrinh, thang, nam);

    final firstDay = "$nam-${thang.toString().padLeft(2, '0')}-01";
    final lastDay = "$nam-${thang.toString().padLeft(2, '0')}-31";
    final ungLuong = await db.rawQuery('''
        SELECT 
          nvct.id as id_nvct,
          ul.soTien
        FROM ung_luong ul
        JOIN nhan_vien_cong_trinh nvct 
          ON nvct.id = ul.idNhanVienCongTrinh
        WHERE ul.ngayUng BETWEEN ? AND ?
          AND nvct.idCongTrinh = ?
      ''', [firstDay, lastDay, idCongTrinh]);

    Map<int, List<DaUng>> daUngMap = {};
    for (var row in ungLuong) {
      final id = (row['id_nvct'] as num).toInt();
      daUngMap.putIfAbsent(id, () => []);
      daUngMap[id]!.add(
        DaUng(
          tienUng: (row['soTien'] as num).toDouble(),
        ),
      );
    }

    Map<int, ChamCongModel> map = {};
    for (var row in raw) {
      final id = (row['id_nvct'] as num).toInt();
      if (!map.containsKey(id)) {
        map[id] = ChamCongModel(
          ten: row['ho_ten'] ?? '',
          chucVu: row['vaiTro'] ?? '',
          idNhanVienCongTrinh: row['id_nvct'],
          daUng: daUngMap[id] ?? [],
          data: {},
          trangThai: 0,
        );
      }

      /// 👉 thêm dữ liệu ngày
      if (row['ngay'] != null) {
        final sang =
            TrangThaiChamCong.fromValue(row['trang_thai_sang'] as int?);
        final chieu =
            TrangThaiChamCong.fromValue(row['trang_thai_chieu'] as int?);
        final chamCongNgay = ChamCongNgay(
          sang: sang,
          chieu: chieu,
        );
        final luongNgay = (row['luongNgay'] as num?)?.toDouble() ?? 0.0;
        final ngay = row['ngay'] as String?;
        if (ngay == null) continue;
        map[id]!.data[ngay] = ChamCongNgayLuong(
          chamCong: chamCongNgay,
          luongNgay: luongNgay,
        );
      }
    }

    return map.values.toList();
  }

  // Lấy lương cơ bản, trạng thái sáng, chiều, công ngày, tiền công ngày
  Future<ChamCongNgayLuong?> getChamCongNgayLuong(
      int idNhanVienCongTrinh, String ngay) async
  {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
    SELECT 
      cc.trang_thai_sang,
      cc.trang_thai_chieu,

      -- 👉 lấy lương theo ngày
      (
        SELECT lcb.mucLuong
        FROM luong_co_ban lcb
        JOIN nhan_vien_cong_trinh nvct 
          ON nvct.idNhanVien = lcb.idNhanVien
        WHERE nvct.id = ?
          AND (lcb.ngayApDung IS NULL OR lcb.ngayApDung <= cc.ngay)
        ORDER BY lcb.ngayApDung DESC
        LIMIT 1
      ) as luongNgay

    FROM cham_cong cc
    WHERE cc.id_nhan_vien_cong_trinh = ?
      AND cc.ngay = ?
  ''', [idNhanVienCongTrinh, idNhanVienCongTrinh, ngay]);

    /// 👉 không có dữ liệu
    if (result.isEmpty) return null;
    final row = result.first;
    final sang = TrangThaiChamCong.fromValue(row['trang_thai_sang'] as int?);
    final chieu = TrangThaiChamCong.fromValue(row['trang_thai_chieu'] as int?);
    final chamCongNgay = ChamCongNgay(
      sang: sang,
      chieu: chieu,
    );
    final luongNgay = (row['luongNgay'] as num?)?.toDouble() ?? 0.0;
    return ChamCongNgayLuong(
      chamCong: chamCongNgay,
      luongNgay: luongNgay,
    );
  }

  // *********CHẤM CÔNG ************
  Future<void> updateChamCong({
    required int idNhanVienCongTrinh,
    required String ngay,
    TrangThaiChamCong? sang,
    TrangThaiChamCong? chieu,
  }) async {
    final db = await _dbHelper.database;
    final existing = await db.query(
      'cham_cong',
      where: 'id_nhan_vien_cong_trinh = ? AND ngay = ?',
      whereArgs: [idNhanVienCongTrinh, ngay],
    );
    if (existing.isNotEmpty)
    {
      await db.update(
        'cham_cong',
        {
          'trang_thai_sang': sang?.value,
          'trang_thai_chieu': chieu?.value,
        },
        where: 'id_nhan_vien_cong_trinh = ? AND ngay = ?',
        whereArgs: [idNhanVienCongTrinh, ngay],
      );
    } else {
      await db.insert(
        'cham_cong',
        {
          'id_nhan_vien_cong_trinh': idNhanVienCongTrinh,
          'ngay': ngay,
          'trang_thai_sang': sang?.value,
          'trang_thai_chieu': chieu?.value,
          'ngay_tao': DateTime.now().toIso8601String(),
        },
      );
    }
  }
}
