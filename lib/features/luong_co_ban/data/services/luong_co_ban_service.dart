import 'package:nhat_ky_xay_dung/data/tables/luong_co_ban_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_table.dart';

import '../../../../data/db_helper.dart';
import '../models/LuongCoBan.dart';
import '../../../nhan_vien/data/models/NhanVien.dart';
import '../repositories/luong_coban_repository.dart';
import '../../../nhan_vien/data/services/nhan_vien_service.dart';

class LuongCoBanService {
  final _dbHelper = DBHelper.instance;
  final LuongCoBanRepository _repo = LuongCoBanRepository();

  Future<void> addLuongCoBan(Luongcoban luong) async {
    await _repo.insert(luong);
  }

  Future<void> updateLuongCoBan(Luongcoban luong) async {
    await _repo.update(luong);
  }

  Future<void> deleteLuongCoBan(int id) async {
    await _repo.delete(id);
  }

  Future<List<Luongcoban>> getAllLuongCoBan() async {
    return await _repo.getAll();
  }

  Future<LuongCoBanViewModel> getAllGroupedByNhanVien() async {
    // 1. Lấy danh sách lương cơ bản và nhân viên
    final luongs = await _repo.getAll(); // List<Luongcoban>
    final nhanViens =
        await NhanVienService().getAllNhanVien(); // List<NhanVien>

    // 2. Map từng Luongcoban với NhanVien
    final List<Luongcoban> luongsMapped = luongs.map((l) {
      final nv = nhanViens.firstWhere(
        (e) => e.id == l.idNhanVien,
        orElse: () => NhanVien(id: l.idNhanVien, hoTen: "Không tên"),
      );
      return l.copyWith(idNhanVien: l.idNhanVien, nhanVien: nv);
    }).toList();

    // 3. Group theo nhân viên
    final Map<int, List<Luongcoban>> grouped = {};
    for (var l in luongsMapped) {
      grouped.putIfAbsent(l.idNhanVien, () => []).add(l);
    }

    // 4. Chuyển sang ViewModel
    final List<LuongNhanVienViewModel> nhanVienModels =
        grouped.entries.map((entry) {
      final nv = entry.value.first.nhanVien!;
      return LuongNhanVienViewModel()
        ..nhanVien = nv
        ..luongCoBans = entry.value;
    }).toList();

    return LuongCoBanViewModel()..luongNhanViens = nhanVienModels;
  }

  Future<List<Luongcoban>> getLuongCoBanByNhanVien(int idNhanVien) async {
    return await _repo.getByNhanVien(idNhanVien);
  }

  /// Lấy mức lương hiện tại của nhân viên (mới nhất theo ngày áp dụng)
  Future<Luongcoban?> getLuongHienTai(int idNhanVien) async {
    final ds = await _repo.getByNhanVien(idNhanVien);
    if (ds.isNotEmpty) return ds.first;
    return null;
  }

  Future<List<LuongCoBanModel>> getLuongCoBan() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
    SELECT 
      nv.${NhanVienTable.id} as idNhanVien,
      nv.${NhanVienTable.hoTen},
      nv.${NhanVienTable.soDienThoai},
      nv.${NhanVienTable.ngaySinh},
      lcb.${LuongCoBanTable.mucLuong} as luongHienTai
    FROM ${NhanVienTable.tableName} nv
    LEFT JOIN ${LuongCoBanTable.tableName} lcb 
      ON lcb.${LuongCoBanTable.idNhanVien} = nv.${NhanVienTable.id}
      AND lcb.${LuongCoBanTable.id} = (
        SELECT id FROM ${LuongCoBanTable.tableName}
        WHERE idNhanVien = nv.${NhanVienTable.id}
        ORDER BY ngayApDung DESC, ngayTao DESC
        LIMIT 1
      )
  ''');
    return result.map((e) {
      return LuongCoBanModel(
        idNhanVien: e['idNhanVien'] as int,
        hoTen: e['ho_ten'] as String?,
        soDienThoai: e['so_dien_thoai'] as String?,
        ngaySinh: e['ngay_sinh'] as String?,
        luongHienTai: e['luongHienTai'] != null
            ? (e['luongHienTai'] as num).toDouble()
            : 0,
      );
    }).toList();
  }
  Future<List<LuongCoBanNhanVienModel>> getLuongCoBanNhanVien(int idNhanVien) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      '${LuongCoBanTable.tableName}',
      where: '${LuongCoBanTable.idNhanVien} = ?',
      whereArgs: [idNhanVien],
      orderBy: '${LuongCoBanTable.ngayApDung} DESC, ${LuongCoBanTable.ngayTao} DESC',
    );

    return result.map((e) {
      return LuongCoBanNhanVienModel(
        id: e['id'] as int ,
        soTien: (e['mucLuong'] as num?)?.toDouble(),
        ngayApDung: e['ngayApDung'] != null
            ? DateTime.tryParse(e['ngayApDung'] as String)
            : null,
        ghiChu: e['ghiChu'] as String?,
      );
    }).toList();
  }
}
