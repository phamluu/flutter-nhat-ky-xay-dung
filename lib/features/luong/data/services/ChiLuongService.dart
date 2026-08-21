import '../models/ChiLuong.dart';
import '../repositories/ChiLuongRepository.dart';

class ChiLuongService {
  final ChiLuongRepository repo;

  ChiLuongService(this.repo);

  Future<void> chiLuong({
    required int idBangLuong,
    required double soTien,
    DateTime? ngayChi,
    String? ghiChu,
  }) async {
    final model = ChiLuongModel(
      idBangLuong: idBangLuong,
      soTien: soTien,
      ngayChi: ngayChi ?? DateTime.now(),
      ghiChu: ghiChu,
      createdAt: DateTime.now(),
    );

    await repo.insert(model);
  }

  Future<List<ChiLuongModel>> getLichSu(int idBangLuong) {
    return repo.getByBangLuong(idBangLuong);
  }

  Future<double> getTongDaChi(int idBangLuong) {
    return repo.getTongDaChi(idBangLuong);
  }
  Future<void> deleteChiLuong(int id) async {
    await repo.delete(id);
  }

  Future<List<ChiLuongModel>> getByCongTrinhThangNam(int idCongTrinh, int thang, int nam)
  {
    return repo.getByCongTrinhThangNamWithNhanVien(idCongTrinh, thang, nam);
  }
}