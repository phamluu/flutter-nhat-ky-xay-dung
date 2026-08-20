import '../../../../core/utils/trang_thai_luong.dart';
import '../repositories/ChotChiLuongRepository.dart';
import '../models/ChamCongModel.dart';
import 'cham_cong_service.dart';

class BangLuongService {
  final ChamCongService chamCongService;
  final ChotChiLuongRepository chotRepo;

  BangLuongService({
    required this.chamCongService,
    required this.chotRepo,
  });

  Future<List<ChamCongModel>> loadLuong(
      int idCongTrinh, int thang, int nam) async {

    final chamCongList = await chamCongService.loadChamCong(idCongTrinh, thang, nam);

    final bangLuongList =
    await chotRepo.getBangLuongByCongTrinh(idCongTrinh, thang, nam);

    /// map bảng lương
    Map<int, Map<String, dynamic>> mapLuong = {
      for (var e in bangLuongList)
        (e['idNhanVienCongTrinh'] as num).toInt(): e
    };

    for (var nv in chamCongList) {
      final bl = mapLuong[nv.idNhanVienCongTrinh];
      if (bl != null) {
        nv.idBangLuong = bl['id'];
        // nv.data.clear();
        //nv.daUng?.clear();
        nv.tongUngChot = bl['tongUng'];
        nv.tongLuongChot = bl['tongLuong'];
        nv.thucNhanChot = bl['thucNhan'];
        nv.trangThai = bl['trangThai'];
        final tongDaChi = await chotRepo.getTongDaChi(nv.idBangLuong!);
        nv.tongDaChi = tongDaChi;
      } else {
        nv.trangThai = TrangThaiLuong.chuachot.value;
      }
    }

    return chamCongList;
  }
}