import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/models/bang_luong.dart';

import '../repositories/ChotChiLuongRepository.dart';
import '../models/ChamCongModel.dart';

class Chotchiluongservice {
  final ChotChiLuongRepository repo;
  Chotchiluongservice(this.repo);
  /// 👉 chốt lương
  Future<void> chotLuong({
    required ChamCongNhanVienModel nv,
    required int idBangChamCong
  }) async
  {
    final id =await repo.upsertBangLuong(
      BangLuong(
          idNhanVienCongTrinh: nv.idNhanVienCongTrinh!,
          idBangChamCong: idBangChamCong,
          tongCong: nv.tongSoCong ?? 0,
          tongLuong: nv.tongTienCong ?? 0,
          tongUng: nv.tongUng ?? 0,
          thucNhan: nv.thucNhan ?? 0)
    );
    await repo.chotLuong(id);
  }

  /// 👉 kiểm tra đã chốt chưa
  Future<bool> isDaChotLuong(int idNvct, int idBangChamCong) async {
    final data = await repo.checkDaChotLuong(idBangChamCong, idNvct);
    return data;
  }
  Future<bool> isTonTaiDaChotLuong(int? idBangChamCong) async {
    final data = await repo.tonTaiDaChotLuong(idBangChamCong);
    return data;
  }
  // Kiểm tra tồn tại nhân viên đã được chốt lương
  Future<bool> isTonTaiChotLuong(int idBangChamCong) async {
    final data = await repo.tonTaiDaChotLuong(idBangChamCong);
    return data;
  }
  Future<Set<int>> getDanhSachDaChot(
      int idCongTrinh, int idBangChamCong) async {
    final data = await repo.getDanhSachDaChot(idCongTrinh, idBangChamCong);
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
    await repo.huyChot(idBangLuong);
  }
}
