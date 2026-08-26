import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/models/bang_luong.dart';

import '../repositories/ChotChiLuongRepository.dart';
import '../models/ChamCongModel.dart';

class Chotchiluongservice {
  final ChotChiLuongRepository repo;
  Chotchiluongservice(this.repo);
  Future<bool> isTonTaiDaChotLuong(int? idBangChamCong) async {
    final data = await repo.tonTaiDaChotLuong(idBangChamCong);
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
}
