import '../data/repositories/ChotChiLuongRepository.dart';
import '../viewmodel/ChamCongModel.dart';

class Chotchiluongservice {
  final ChotChiLuongRepository repo;

  Chotchiluongservice(this.repo);

  /// 👉 chốt lương
  Future<void> chotLuong({
    required ChamCongModel nv,
    required int thang,
    required int nam,
  }) async {
    await repo.upsertBangLuong(
      idNhanVienCongTrinh: nv.idNhanVienCongTrinh!,
      thang: thang,
      nam: nam,
      tongCong: nv.tongSoCong ?? 0,
      tongLuong: nv.tongTienCong ?? 0,
      tongUng: nv.tongUng ?? 0,
      thucNhan: nv.thucNhan ?? 0,
    );
  }

  /// 👉 kiểm tra đã chốt chưa
  Future<bool> isDaChot(int idNvct, int thang, int nam) async {
    final data = await repo.getBangLuong(idNvct, thang, nam);
    return data != null;
  }

  Future<Set<int>> getDanhSachDaChot(
      int idCongTrinh, int thang, int nam) async {
    final data = await repo.getDanhSachDaChot(idCongTrinh, thang, nam);
    return data;
  }

  /// 👉 chi lương
  Future<void> chiLuong(
      {required int idBangLuong,
      required double soTien,
      String? ghiChu}) async {
    await repo.insertChiLuong(
        idBangLuong: idBangLuong, soTien: soTien, ghiChu: ghiChu);
  }

  Future<void> huyChot({required int idBangLuong}) async {
    await repo.delete(idBangLuong);
  }
}
