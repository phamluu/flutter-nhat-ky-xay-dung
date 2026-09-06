import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/ChotChiLuongRepository.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/bang_cham_cong_repo.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/cham_cong_chi_tiet_repo.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/cham_cong_luong_repo.dart';
import 'package:nhat_ky_xay_dung/features/cong_trinh/data/respositories/nhan_vien_cong_trinh_repo.dart';
import 'package:nhat_ky_xay_dung/features/luong/data/repositories/ung_luong_repository.dart';

import '../../../../core/utils/trang_thai_cham_cong.dart';
import '../../../luong/data/enums.dart';
import '../models/bang_cham_cong.dart';
import '../models/bang_luong.dart';
import '../models/ChamCongModel.dart';

class ChamCongService {
  final ChamCongChiTietRepo repo;
  final BangChamCongRepository bangChamCongrepo;
  final NhanVienCongTrinhRepo _nhanVienCongTrinhRepo;
  final UngLuongRepository _ungLuongRepo;
  final ChotChiLuongRepository _bangLuongRepo;
  final ChamCongLuongRepo _chamCongLuongRepo;
  ChamCongService(this.repo, this.bangChamCongrepo, this._nhanVienCongTrinhRepo, this._ungLuongRepo, this._bangLuongRepo, this._chamCongLuongRepo);
  /// Dành cho bảng chấm công
  /// Nếu chưa có bảng chấm công vẫn load danh sách nhân viên oông trình
  Future<List<ChamCongLuongNhanVienModel>> chamCongNhanViens({ required int idCongTrinh, int? idBangChamCong}) async {
    final danhSachNhanVien = await _nhanVienCongTrinhRepo.getDanhSachNhanVien(idCongTrinh);
    final dataChamCong = await repo.chamCongs(idBangChamCong: idBangChamCong);
    final List<ChamCongLuongNhanVienModel> result = [];
    for (var nv in danhSachNhanVien) {
      final Map<String, ChamCongNgayLuong> mapData = {};
      for (var c in dataChamCong.where((c) => c.idNhanVienCongTrinh == nv.id)) {
        if (c.ngay != null) {
          final luongCoBan = await repo.luongNgayForNhanVien(idNhanVienCongTrinh: c.idNhanVienCongTrinh, ngay: c.ngay);
          mapData[c.ngay!] = ChamCongNgayLuong(
            chamCong: ChamCongNgay(
              id: c.id,
              sang: TrangThaiChamCong.fromValue(c.trangThaiSang),
              chieu: TrangThaiChamCong.fromValue(c.trangThaiChieu),
              ghiChu: c.ghiChu ?? '',
              idPhienChot: c.idPhienChot,
            ),
             luongNgay: luongCoBan.mucLuong!,
              luongCoBan: luongCoBan
          );
        }
      }
      // Tính tổng ứng còn lại không tính kì này
       //final tongDaUng = await _chamCongLuongRepo.tongTienUngLuongForNhanVien(idNhanVienCongTrinh: nv.id!, idBangChamCong: idBangChamCong);
      // Tính trừ ứng trong toàn bộ bảng chấm công kỳ ngày
      final truUngKyNay = await _ungLuongRepo.tongTruUngForChamCong(idBangChamCong, nv.id);
      final tongUng = await _ungLuongRepo.tongUngConLaiForChamCong(idBangChamCong, nv.id);
      // final tongDaChi = await _bangLuongRepo.tongDaChi(bangLuong?.id);
      // Tổng trừ ứng trong bảng chấm công này

      // 3. Gán vào model nhân viên
      final tongLuongChot = await _chamCongLuongRepo.tongLuongChotForNhanVien( idNhanVienCongTrinh: nv.id, idBangChamCong: idBangChamCong);
      final chamCong = ChamCongNhanVienModel(
        idNhanVienCongTrinh: nv.id,
        ten: nv.tenNhanVien,
        chucVu: nv.vaiTro ?? '',
        data: mapData,
      );

      final luong = LuongNhanVienModel(
        tongUng: tongUng,
        truUng: truUngKyNay,
        trangThaiChotLuong: 0,
        tongLuongChot: tongLuongChot,
        tongUngChot: 0,
        thucNhanChot: 0,
        tongDaChi: 0,
      );
      result.add(
        ChamCongLuongNhanVienModel(
          chamCong: chamCong,
          luong: luong
        ),
      );
    }
    return result;
  }

}