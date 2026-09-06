import 'package:nhat_ky_xay_dung/core/utils/date_utils.dart';

import '../../../../data/tables/phien_chot_cong_table.dart';
import 'ChamCongModel.dart';

class PhienChotCong {
    int? id;
    int? idChamCong;
    String? maDot;
    String? tuNgay;
    int? soLuongNhanVien;
    String? denNgay;
    String? get denNgayStr{
      return DateUtilsCore.formatDate(this.denNgay);
    }
    String? ngayChot;
    String? nguoiChot;
    String? ghiChu;
    String? serverId;
    int? isSynced;
    String? updatedAt;
    PhienChotCong({
      this.id,
      this.idChamCong,
      this.maDot,
      this.tuNgay,
      this.soLuongNhanVien,
      this.denNgay,
      this.ngayChot,
      this.nguoiChot,
      this.ghiChu,
      this.serverId,
      this.isSynced,
      this.updatedAt
  });
    factory PhienChotCong.fromMap(Map<String, dynamic> map){
      return PhienChotCong(
          id: map[PhienChotCongTable.id],
          idChamCong: map[PhienChotCongTable.idChamCong],
          maDot: map[PhienChotCongTable.maDot],
          soLuongNhanVien: map['so_luong_nv'],
          denNgay: map[PhienChotCongTable.denNgay],
          ngayChot: map[PhienChotCongTable.ngayChot],
          ghiChu: map[PhienChotCongTable.ghiChu]
      );
    }
    Map<String, dynamic> toMapInsert() => {
      PhienChotCongTable.idChamCong: idChamCong,
      PhienChotCongTable.maDot: maDot,
      PhienChotCongTable.denNgay: denNgay,
      PhienChotCongTable.ngayChot: DateTime.now().toIso8601String(),
      PhienChotCongTable.nguoiChot: nguoiChot,
      PhienChotCongTable.ghiChu: ghiChu
    };
}
class ChamCongLuongNhanVien {
  final int? idNhanVienCongTrinh;
  final String? hoTen;
  final String? soDienThoai;
  final String? chucVu;

  final double? tongUngDaTru;
  final int? trangThaiLuong;

  // Dự kiến
  double get soCong {
    return data.values.fold(
      0.0,
          (sum, item) => sum + item.chamCong.soCong,
    );
  }
  final double tongUngDuKien;
  double get tongLuongDuKien {
    return data.values.fold(
      0.0,
          (sum, item) => sum + item.tienCongNgay,
    );
  }
  double get thucNhanDuKien{
    return tongLuongDuKien - tongUngDuKien;
  }

  // Chốt
  final double? tongSoCongChot;
  final double? tongUngChot;
  final double? tongLuongChot;
  final double? thucNhanChot;
  final Map<String, ChamCongNgayLuong> data;

  ChamCongLuongNhanVien({
    this.idNhanVienCongTrinh,
    this.hoTen,
    this.soDienThoai,
    this.chucVu,
    required this.tongUngDuKien,
    this.tongUngDaTru,
    this.trangThaiLuong,
    this.tongSoCongChot,
    this.tongUngChot,
    this.tongLuongChot,
    this.thucNhanChot,
    required this.data,
  });

  /// Tự động tính tổng số công từ Map data


  /// Tự động tính tổng lương từ Map data

}