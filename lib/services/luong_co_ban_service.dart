import '../data/models/LuongCoBan.dart';
import '../data/repositories/luong_coban_repository.dart';

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
