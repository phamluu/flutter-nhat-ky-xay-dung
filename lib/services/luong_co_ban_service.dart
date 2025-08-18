import '../data/models/LuongCoBan.dart';
import '../data/models/NhanVien.dart';
import '../data/repositories/luong_coban_repository.dart';
import 'nhan_vien_service.dart';

class LuongCoBanService {
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
    final nhanViens = await NhanVienService().getAllNhanVien(); // List<NhanVien>

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
    final List<LuongNhanVienViewModel> nhanVienModels = grouped.entries.map((entry) {
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
}
