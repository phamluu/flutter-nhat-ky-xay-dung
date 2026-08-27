import 'package:nhat_ky_xay_dung/data/tables/chi_tiet_doi_tru_ung_luong.dart';
import 'package:nhat_ky_xay_dung/data/tables/ung_luong_table.dart';
import 'package:nhat_ky_xay_dung/features/cong_trinh/data/models/CongTrinh.dart';import '../../../cong_trinh/data/models/NhanVienCongTrinh.dart';
import '../../../nhan_vien/data/models/NhanVien.dart';
import 'ChiTietDoiUngTruLuong.dart';

class Ungluong {
    int? id;
    int? idNhanVienCongTrinh;
    double? soTien;
    double? soTienDaTru;
    DateTime? ngayUng;
    int? trangThai;
    String? lyDo;
    final int? isSynced;
    List<ChiTietDoiUngTruLuong>? lstDoiTru;
    double get tongDaTru {
      return lstDoiTru?.fold(
        0.0,
            (sum, item) => sum! + item.soTienDoiTru!,
      ) ?? 0.0;
    }
    double get conLai{
      return this.soTien! - this.tongDaTru;
    }
  Ungluong({
    this.id,
    this.idNhanVienCongTrinh,
    this.soTien,
    this.soTienDaTru,
    this.ngayUng,
    this.trangThai,
    // this.nhanVien,
    // this.nhanVienCongTrinh,
    this.lyDo,
    this.isSynced,
    this.lstDoiTru
  });
    factory Ungluong.fromMap(Map<String, dynamic> map)
    {
      return Ungluong(
        id: map[UngLuongTable.id] as int?,
        idNhanVienCongTrinh: map[UngLuongTable.idNhanVienCongTrinh] as int?,
        soTien: (map[UngLuongTable.soTien] is int)
            ? (map[UngLuongTable.soTien] as int).toDouble()
            : map[UngLuongTable.soTien] as double?,
        soTienDaTru: (map[UngLuongTable.soTienDaTru] is int)
            ? (map[UngLuongTable.soTienDaTru] as int).toDouble()
            : map[UngLuongTable.soTienDaTru] as double?,
        ngayUng: map[UngLuongTable.ngayUng] != null
            ? DateTime.tryParse(map[UngLuongTable.ngayUng].toString())
            : null,
        lyDo: map[UngLuongTable.lyDo] as String?,
        trangThai: map[UngLuongTable.trangThai] as int?,
      );
    }
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      UngLuongTable.idNhanVienCongTrinh: idNhanVienCongTrinh,
      UngLuongTable.soTien: soTien,
      UngLuongTable.trangThai: trangThai,
      UngLuongTable.ngayUng: ngayUng?.toIso8601String(),
      UngLuongTable.lyDo: lyDo,
    };
    return map;
  }

  Ungluong copyWith({
    int? id,
    int? idNhanVienCongTrinh,
    double? soTien,
    int? trangThai,
    DateTime? ngayUng,
    // NhanVien? nhanVien,
    // NhanVienCongTrinh? nhanVienCongTrinh,
    String? lyDo,
  }) {
    return Ungluong(
      id: id ?? this.id,
      idNhanVienCongTrinh: idNhanVienCongTrinh ?? this.idNhanVienCongTrinh,
      soTien: soTien ?? this.soTien,
      ngayUng: ngayUng ?? this.ngayUng,
      trangThai: trangThai ?? this.trangThai,
      // nhanVien: nhanVien ?? this.nhanVien,
      // nhanVienCongTrinh: nhanVienCongTrinh ?? this.nhanVienCongTrinh,
      lyDo: lyDo ?? this.lyDo,
    );
  }

  int? operator [](String other) {}
}

// Theo danh sách nhân viên

class UngLuongItem{
  double soTien;
  double soTienDaTru;
  DateTime? ngayUng;
  String? lyDo;
  UngLuongItem({
    required this.soTien,
    required this.soTienDaTru,
    this.ngayUng,
    this.lyDo
});
}

class UngLuongViewModel{
  int idNhanVienCongTrinh;
  int? thang;
  int? nam;
  final String? hoTen;
  final List<UngLuongItem> daUngs;
  UngLuongViewModel({
    required this.idNhanVienCongTrinh,
    this.hoTen,
    this.thang,
    this.nam,
    required this.daUngs,
  });
  double get tongUng {
    return daUngs.fold(
      0.0,
          (sum, item) => sum! + item.soTien,
    ) ?? 0.0;
  }
  double get tongDoiTru {
    return daUngs.fold(
      0.0,
          (sum, item) => sum! + item.soTienDaTru,
    ) ?? 0.0;
  }
}