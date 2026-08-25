import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/bang_cham_cong_repo.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/cham_cong_chi_tiet_repo.dart';
import 'package:nhat_ky_xay_dung/features/cong_trinh/data/respositories/nhan_vien_cong_trinh_repo.dart';
import 'package:nhat_ky_xay_dung/features/luong/data/repositories/ung_luong_repository.dart';

import '../../../../core/utils/trang_thai_cham_cong.dart';
import '../../../luong/data/enums.dart';
import '../models/bang_cham_cong.dart';
import '../repositories/ChamCongRepository.dart';
import '../models/ChamCongModel.dart';

class ChamCongService {
  final ChamCongChiTietRepo repo;
  final BangChamCongRepository bangChamCongrepo;
  final NhanVienCongTrinhRepo _nhanVienCongTrinhRepo;
  final UngLuongRepository _ungLuongRepo;
  ChamCongService(this.repo, this.bangChamCongrepo, this._nhanVienCongTrinhRepo, this._ungLuongRepo);
  /// Dành cho bảng chấm công
  /// Nếu chưa có bảng chấm công vẫn load danh sách nhân viên oông trình

  // Future<List<ChamCongNhanVienModel>> chamCongNhanViens({int? idCongTrinh, int? thang, int? nam, int? idBangChamCong})
  //     async {
  //       // Lấy danh sách nhân viên công trình
  //       final danhSachNhanVien = await _nhanVienCongTrinhRepo.getDanhSachNhanVien(idCongTrinh!);
  //       // Lấy dữ liệu chi tiết
  //       final dataChamCong = await repo.chamCongs(idBangChamCong: idBangChamCong);
  //       return danhSachNhanVien.map((nv) {
  //         // 1. Lọc dữ liệu chấm công của nhân viên hiện tại
  //         final listChamCongOfNv = dataChamCong.where((item) => item.idNhanVienCongTrinh == nv.id);
  //
  //         // 2. Map dữ liệu vào Map<String, ChamCongNgayLuong>
  //         final Map<String, ChamCongNgayLuong> mapData = {
  //           for (var item in listChamCongOfNv)
  //             if (item.ngay != null)
  //               item.ngay!: ChamCongNgayLuong(
  //                 chamCong: ChamCongNgay(
  //                   id: item.id, // 👈 Gán ID bản ghi chi tiết tại đây
  //                   sang: TrangThaiChamCong.fromValue(item.trangThaiSang),
  //                   chieu: TrangThaiChamCong.fromValue(item.trangThaiChieu),
  //                   ghiChu: item.ghiChu ?? '',
  //                 ),
  //                 luongNgay:  0.0,
  //               )
  //         };
  //
  //         // 3. Trả về Model hoàn chỉnh
  //         return ChamCongNhanVienModel(
  //           idNhanVienCongTrinh: nv.id,
  //           ten:  '',
  //           chucVu: nv.vaiTro ?? '',
  //           data: mapData,
  //           // daUng: mapUngLuong[nv.id] ?? [],
  //           trangThaiChotLuong: 0,
  //           tongDaChi: 0.0,
  //         );
  //       }).toList();
  //
  //
  //
  //
  //       final Map<int, Map<String, ChamCongNgayLuong>> mapChamCong = {};
  //       for (var item in dataChamCong) {
  //         if (item.idNhanVienCongTrinh == null || item.ngay == null) continue;
  //         final idNV = item.idNhanVienCongTrinh!;
  //         mapChamCong.putIfAbsent(idNV, () => {});
  //         mapChamCong[idNV]![item.ngay!] = ChamCongNgayLuong(
  //           chamCong: ChamCongNgay(
  //             sang: TrangThaiChamCong.fromValue(item.trangThaiSang),
  //             chieu: TrangThaiChamCong.fromValue(item.trangThaiChieu),
  //             ghiChu: item.ghiChu ?? '',
  //           ),
  //           luongNgay: item.luongNgay ?? 0.0,
  //         );
  //       }
  //
  //
  //       final firstDay = "$nam-${thang.toString().padLeft(2, '0')}-01";
  //       final lastDay = "$nam-${thang.toString().padLeft(2, '0')}-31";
  //
  //
  //
  //       // 🔹 lấy raw data từ repository
  //       final rawChamCong =
  //           await repo.getChamCongRaw(idCongTrinh, firstDay, lastDay);
  //
  //       final rawUngLuong =
  //           await repo.getUngLuongRaw(idCongTrinh, firstDay, lastDay);
  //       /// 👉 map ứng lương
  //       Map<int, List<DaUng>> daUngMap = {};
  //       for (var row in rawUngLuong) {
  //         final id = (row['id_nvct'] as num).toInt();
  //         daUngMap.putIfAbsent(id, () => []);
  //         daUngMap[id]!.add(
  //           DaUng(
  //             tienUng: (row['soTien'] as num).toDouble(),
  //           ),
  //         );
  //       }
  //       /// 👉 map chấm công
  //       Map<int, ChamCongNhanVienModel> map = {};
  //       for (var row in rawChamCong) {
  //         final id = (row['id_nvct'] as num).toInt();
  //         /// tạo nhân viên nếu chưa có
  //         if (!map.containsKey(id)) {
  //           map[id] = ChamCongNhanVienModel(
  //               ten: row['ho_ten'] ?? '',
  //               chucVu: row['vaiTro'] ?? '',
  //               idNhanVienCongTrinh: id,
  //               daUng: daUngMap[id] ?? [],
  //               data: {},
  //               trangThaiChotLuong: 0,
  //               tongDaChi: 0
  //           );
  //         }
  //         /// 👉 thêm dữ liệu ngày
  //         if (row['ngay'] != null) {
  //           final sang = TrangThaiChamCong.fromValue(
  //               row['trang_thai_sang'] as int?);
  //
  //           final chieu = TrangThaiChamCong.fromValue(
  //               row['trang_thai_chieu'] as int?);
  //
  //           final chamCongNgay = ChamCongNgay(
  //             sang: sang,
  //             chieu: chieu,
  //             ghiChu: (row['ghi_chu'] ?? '').toString(),
  //           );
  //           final luongNgay =
  //               (row['luongNgay'] as num?)?.toDouble() ?? 0.0;
  //           final ngay = row['ngay'] as String;
  //           map[id]!.data[ngay] = ChamCongNgayLuong(
  //             chamCong: chamCongNgay,
  //             luongNgay: luongNgay,
  //           );
  //         }
  //       }
  //       return map.values.toList();
  //     }

  Future<List<ChamCongNhanVienModel>> chamCongNhanViens({ required int idCongTrinh, int? idBangChamCong}) async {
    final danhSachNhanVien = await _nhanVienCongTrinhRepo.getDanhSachNhanVien(idCongTrinh);
    final dataChamCong = await repo.chamCongs(idBangChamCong: idBangChamCong);
    // final dataUngLuong = await _ungLuongRepo.getDanhSachUngLuong(idBangChamCong: idBangChamCong);
    final List<ChamCongNhanVienModel> result = [];
    for (var nv in danhSachNhanVien) {
      // 1. Lấy danh sách ứng lương của NV
      // final listUng = dataUngLuong
      //     .where((u) => u.idNhanVienCongTrinh == nv.id)
      //     .map((u) => DaUng(tienUng: u.soTien ?? 0.0))
      //     .toList();

      // 2. Map dữ liệu chấm công theo ngày ('YYYY-MM-DD')

      final Map<String, ChamCongNgayLuong> mapData = {};
      for (var c in dataChamCong.where((c) => c.idNhanVienCongTrinh == nv.id)) {
        if (c.ngay != null) {
          mapData[c.ngay!] = ChamCongNgayLuong(
            chamCong: ChamCongNgay(
              id: c.id,
              sang: TrangThaiChamCong.fromValue(c.trangThaiSang),
              chieu: TrangThaiChamCong.fromValue(c.trangThaiChieu),
              ghiChu: c.ghiChu ?? '',
            ),
             luongNgay: await repo.luongNgayForNhanVien(idnhanVienCongTrinh: c.idNhanVienCongTrinh, ngay: c.ngay),
          );
        }
      }
      final ungLuongs = await _ungLuongRepo.tongTienUngLuongForNhanVien(idNhanVienCongTrinh: nv.id!, loai: LoaiTongUngLuong.chuaDoiTru);
      // 3. Gán vào model nhân viên
      result.add(
        ChamCongNhanVienModel(
          idNhanVienCongTrinh: nv.id,
          ten: nv.tenNhanVien,
          chucVu: nv.vaiTro ?? '',
          data: mapData,
          // Toàn bộ số tiền đã ứng mà chưa trừ
          tongUng: ungLuongs,
          trangThaiChotLuong: 0,
          tongDaChi: 0.0,
        ),
      );
    }
    return result;
  }
  /// 📌 Lấy chấm công + lương 1 ngày
  // Future<ChamCongNgayLuong?> getChamCongNgayLuong({int? id, int? idNhanVienCongTrinh, String? ngay}) async
  // {
  //   final result =
  //   await repo.getChamCongNgay(idNhanVienCongTrinh, ngay);
  //   if (result.isEmpty) return null;
  //   final row = result.first;
  //   final sang = TrangThaiChamCong.fromValue(
  //       row['trang_thai_sang'] as int?);
  //   final chieu = TrangThaiChamCong.fromValue(
  //       row['trang_thai_chieu'] as int?);
  //   final chamCongNgay = ChamCongNgay(
  //     sang: sang,
  //     chieu: chieu,
  //     ghiChu: (row['ghi_chu'] ?? '').toString(),
  //   );
  //   final luongNgay =
  //       (row['luongNgay'] as num?)?.toDouble() ?? 0.0;
  //   return ChamCongNgayLuong(
  //     chamCong: chamCongNgay,
  //     luongNgay: luongNgay,
  //   );
  // }
  //

}