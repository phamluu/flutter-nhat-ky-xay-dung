import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/ChotChiLuongRepository.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/bang_cham_cong_repo.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/cham_cong_chi_tiet_repo.dart';
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
  ChamCongService(this.repo, this.bangChamCongrepo, this._nhanVienCongTrinhRepo, this._ungLuongRepo, this._bangLuongRepo);
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
          );
        }
      }
      BangLuong? bangLuong = await _bangLuongRepo.getBangLuongForNhanVien(idBangChamCong, nv.id);
      final ungLuongs = await _ungLuongRepo.tongTienUngLuongForNhanVien(idNhanVienCongTrinh: nv.id!, idBangLuong: bangLuong?.id);
      final truUng = await _ungLuongRepo.tongTruUng(bangLuong?.id);
      final tongDaChi = await _bangLuongRepo.tongDaChi(bangLuong?.id);
      // 3. Gán vào model nhân viên

      final chamCong = ChamCongNhanVienModel(
        idNhanVienCongTrinh: nv.id,
        ten: nv.tenNhanVien,
        chucVu: nv.vaiTro ?? '',
        data: mapData,
      );

      final luong = LuongNhanVienModel(
        tongUng: ungLuongs,
        truUng: truUng,
        trangThaiChotLuong: bangLuong?.trangThai,
        idBangLuong: bangLuong?.id,
        tongLuongChot: bangLuong?.tongLuong,
        tongUngChot: bangLuong?.tongUng,
        thucNhanChot: bangLuong?.thucNhan,
        tongDaChi: tongDaChi,
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