import '../core/utils/trang_thai_cham_cong.dart';
import '../data/repositories/ChamCongRepository.dart';
import '../viewmodel/ChamCongModel.dart';

class ChamCongService {
  final ChamCongRepository repo;
  ChamCongService(this.repo);
  /// 📌 Load chấm công theo tháng
  Future<List<ChamCongModel>> loadChamCong(
      int idCongTrinh, int thang, int nam) async {
    final firstDay = "$nam-${thang.toString().padLeft(2, '0')}-01";
    final lastDay = "$nam-${thang.toString().padLeft(2, '0')}-31";
    // 🔹 lấy raw data từ repository
    final rawChamCong =
    await repo.getChamCongRaw(idCongTrinh, firstDay, lastDay);
    final rawUngLuong =
    await repo.getUngLuongRaw(idCongTrinh, firstDay, lastDay);
    /// 👉 map ứng lương
    Map<int, List<DaUng>> daUngMap = {};
    for (var row in rawUngLuong) {
      final id = (row['id_nvct'] as num).toInt();
      daUngMap.putIfAbsent(id, () => []);
      daUngMap[id]!.add(
        DaUng(
          tienUng: (row['soTien'] as num).toDouble(),
        ),
      );
    }
    /// 👉 map chấm công
    Map<int, ChamCongModel> map = {};
    for (var row in rawChamCong) {
      final id = (row['id_nvct'] as num).toInt();
      /// tạo nhân viên nếu chưa có
      if (!map.containsKey(id)) {
        map[id] = ChamCongModel(
          ten: row['ho_ten'] ?? '',
          chucVu: row['vaiTro'] ?? '',
          idNhanVienCongTrinh: id,
          daUng: daUngMap[id] ?? [],
          data: {},
          trangThai: 0,
          tongDaChi: 0
        );
      }
      /// 👉 thêm dữ liệu ngày
      if (row['ngay'] != null) {
        final sang = TrangThaiChamCong.fromValue(
            row['trang_thai_sang'] as int?);

        final chieu = TrangThaiChamCong.fromValue(
            row['trang_thai_chieu'] as int?);

        final chamCongNgay = ChamCongNgay(
          sang: sang,
          chieu: chieu,
          ghiChu: (row['ghi_chu'] ?? '').toString(),
        );
        final luongNgay =
            (row['luongNgay'] as num?)?.toDouble() ?? 0.0;
        final ngay = row['ngay'] as String;
        map[id]!.data[ngay] = ChamCongNgayLuong(
          chamCong: chamCongNgay,
          luongNgay: luongNgay,
        );
      }
    }
    return map.values.toList();
  }
  /// 📌 Lấy chấm công + lương 1 ngày
  Future<ChamCongNgayLuong?> getChamCongNgayLuong(
      int idNhanVienCongTrinh, String ngay) async
  {
    final result =
    await repo.getChamCongNgay(idNhanVienCongTrinh, ngay);
    if (result.isEmpty) return null;
    final row = result.first;
    final sang = TrangThaiChamCong.fromValue(
        row['trang_thai_sang'] as int?);
    final chieu = TrangThaiChamCong.fromValue(
        row['trang_thai_chieu'] as int?);
    final chamCongNgay = ChamCongNgay(
      sang: sang,
      chieu: chieu,
      ghiChu: (row['ghi_chu'] ?? '').toString(),
    );
    final luongNgay =
        (row['luongNgay'] as num?)?.toDouble() ?? 0.0;
    return ChamCongNgayLuong(
      chamCong: chamCongNgay,
      luongNgay: luongNgay,
    );
  }

  /// 📌 Cập nhật chấm công (business gọi repo)
  Future<void> updateChamCong({
    required int idNhanVienCongTrinh,
    required String ngay,
    TrangThaiChamCong? sang,
    TrangThaiChamCong? chieu,
    String? ghiChu,
  }) async
  {
    await repo.upsertChamCong(
      idNhanVienCongTrinh: idNhanVienCongTrinh,
      ngay: ngay,
      trangThaiSang: sang?.value,
      trangThaiChieu: chieu?.value,
      ghiChu: ghiChu,
    );
  }
  Future<void> setKhoaChamCong(String thang, bool daKhoa) async{
    await repo.setKhoaChamCong(thang, daKhoa);
  }
  Future<bool> checkKhoaChamCong(String thang) async {
    return await repo.checkKhoaChamCong(thang);
  }
}