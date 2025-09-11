import 'package:intl/intl.dart';
import 'package:nhat_ky_xay_dung/data/models/ChamCong.dart';
import 'package:nhat_ky_xay_dung/data/models/NhanVienCongTrinh.dart';
import 'package:nhat_ky_xay_dung/services/cong_trinh_service.dart';
import 'package:nhat_ky_xay_dung/services/nhan_vien_cong_trinh_service.dart';
import 'package:nhat_ky_xay_dung/data/repositories/cham_cong_repository.dart';

class ChamCongController {
  final ChamCongRepository _repo = ChamCongRepository();
  final CongTrinhService _congTrinhService = CongTrinhService();
  final NhanVienCongTrinhService _nhanVienCongTrinhService = NhanVienCongTrinhService();

  /// Lấy danh sách công trình
  Future<List<Map<String, dynamic>>> loadDsCongTrinh() async {
    final ds = await _congTrinhService.getDanhSachCongTrinh();
    return ds.map<Map<String, dynamic>>((ct) => {
      "id": ct.id,
      "ten": ct.ten,
    }).toList();
  }

  /// Lấy danh sách nhân viên theo công trình
  Future<List<NhanVienCongTrinh>> loadDsNhanVien(int congTrinhId) async {
    return await _nhanVienCongTrinhService.getByCongTrinh(congTrinhId);
  }

  Future<List<ChamCong>> loadChamCongKetQua(
      int idCongTrinh) async {

    final data = await _repo.getChamCong(idCongTrinh);

    return data.toList();
  }

  /// Lấy dữ liệu chấm công
  Future<Map<int, ChamCong>> loadChamCong(
      int congTrinhId, DateTime ngay, List<NhanVienCongTrinh> nhanViens) async {
    final String ngayStr = DateFormat("yyyy-MM-dd").format(ngay);

    // Dữ liệu mặc định rỗng
    final Map<int, ChamCong> map = {
      for (var nvct in nhanViens)
        nvct.id!: ChamCong(
          idNhanVienCongTrinh: nvct.id!,
          ngay: ngayStr,
        )
    };

    // Ghi đè dữ liệu đã lưu (nếu có)
    final existing = await _repo.getChamCongByDate(congTrinhId, ngayStr);
    for (var cc in existing) {
      map[cc.idNhanVienCongTrinh] = cc;
    }

    return map;
  }

  /// Lưu dữ liệu chấm công
  Future<void> save(Map<int, ChamCong> data) async {
    for (var cc in data.values) {
      if (cc.id == null) {
        await _repo.insert(cc);
      } else {
        await _repo.update(cc);
      }
    }
  }
}
