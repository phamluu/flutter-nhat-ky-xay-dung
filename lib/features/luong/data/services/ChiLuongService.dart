import '../../../bang_cham_cong/data/repositories/ChotChiLuongRepository.dart';
import '../models/ChiLuong.dart';
import '../repositories/ChiLuongRepository.dart';

class ChiLuongService {
  final ChiLuongRepository repo;
  final ChotChiLuongRepository _chotRepo;
  ChiLuongService(this.repo, this._chotRepo);

  Future<void> chiLuong({idBangLuong, required double soTien, DateTime? ngayChi, String? ghiChu,}) async {
    // Kiểm tra trạng thái nếu chưa chốt lương thì không được chi
    bool daChotLuong = await _chotRepo.checkDaChotLuong(idBangLuong: idBangLuong);
    if(idBangLuong == null){
      throw Exception('Không có bảng lương');
    }
    if(!daChotLuong){
      throw Exception('Không thể chi lương. Hãy chốt lương trước');
    }
    final model = ChiLuongModel(
      idBangLuong: idBangLuong,
      soTien: soTien,
      ngayChi: ngayChi ?? DateTime.now(),
      ghiChu: ghiChu,
      createdAt: DateTime.now(),
    );

    await repo.insert(model);
  }

  Future<List<ChiLuongModel>> getLichSu(int? idBangLuong) {
    return repo.getByBangLuong(idBangLuong);
  }

  Future<double> getTongDaChi(int? idBangLuong) {
    return repo.getTongDaChi(idBangLuong);
  }
  Future<void> deleteChiLuong(int id) async {
    await repo.delete(id);
  }

  Future<List<ChiLuongModel>> getByCongTrinhThangNam(int idCongTrinh, {String? kyLuong, int?idBangChamCong})
  {
    return repo.getByCongTrinhThangNamWithNhanVien(idCongTrinh, kyLuong: kyLuong, idBangChamCong: idBangChamCong);
  }
}