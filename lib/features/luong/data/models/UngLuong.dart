import 'package:nhat_ky_xay_dung/data/tables/ung_luong_table.dart';
import 'package:nhat_ky_xay_dung/features/cong_trinh/data/models/CongTrinh.dart';import '../../../cong_trinh/data/models/NhanVienCongTrinh.dart';
import '../../../nhan_vien/data/models/NhanVien.dart';

class Ungluong {
    int? id;
    int? idNhanVienCongTrinh;
    double? soTien;
    double? soTienDaTru;
    DateTime? ngayUng;
    int? trangThai;
   NhanVien? nhanVien;
   NhanVienCongTrinh? nhanVienCongTrinh;
    String? lyDo;
    final int? isSynced;

  Ungluong({
    this.id,
    this.idNhanVienCongTrinh,
    this.soTien,
    this.soTienDaTru,
    this.ngayUng,
    this.trangThai,
    this.nhanVien,
    this.nhanVienCongTrinh,
    this.lyDo,
    this.isSynced
  });

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

  factory Ungluong.fromMap(
      Map<String, dynamic> map, {
        List<NhanVienCongTrinh>? nhanVienCongTrinhs,
        List<CongTrinh>? congTrinhs,
        NhanVienCongTrinh? nvct,
      })
  {
    // lấy nhân viên công trình
    if (nhanVienCongTrinhs != null) {
      nvct = nhanVienCongTrinhs.firstWhere(
            (e) => e.id == (map['idNhanVienCongTrinh'] as int?),
        orElse: () => NhanVienCongTrinh(
          id: map['idNhanVienCongTrinh'] as int?,
          idNhanVien: map['idNhanVien'] as int,
          idCongTrinh: map['idCongTrinh'] as int?, // cần có cột này khi query
        ),
      );
    }

    // nếu có danh sách công trình thì map tiếp
    if (nvct != null && congTrinhs != null) {
      final congTrinh = congTrinhs.firstWhere(
            (c) => c.id == nvct!.idCongTrinh,
        orElse: () => CongTrinh(id: nvct!.idCongTrinh, ten: "Không rõ"),
      );
      nvct = NhanVienCongTrinh(
        id: nvct.id,
        idNhanVien: nvct.idNhanVien,
        idCongTrinh: nvct.idCongTrinh,
        ngayBatDau: nvct.ngayBatDau,
        ngayKetThuc: nvct.ngayKetThuc,
        vaiTro: nvct.vaiTro,
        congTrinh: congTrinh,
      );
    }

    return Ungluong(
      id: map[UngLuongTable.id] as int?,
      idNhanVienCongTrinh: map[UngLuongTable.idNhanVienCongTrinh] as int?,
      soTien: (map[UngLuongTable.soTien] is int)
          ? (map[UngLuongTable.soTien] as int).toDouble()
          : map[UngLuongTable.soTien] as double?,
      ngayUng: map[UngLuongTable.ngayUng] != null
          ? DateTime.tryParse(map[UngLuongTable.ngayUng].toString())
          : null,
      lyDo: map[UngLuongTable.lyDo] as String?,
      trangThai: map[UngLuongTable.trangThai] as int?,
      nhanVienCongTrinh: nvct,
    );
  }

  Ungluong copyWith({
    int? id,
    int? idNhanVienCongTrinh,
    double? soTien,
    int? trangThai,
    DateTime? ngayUng,
    NhanVien? nhanVien,
    NhanVienCongTrinh? nhanVienCongTrinh,
    String? lyDo,
  }) {
    return Ungluong(
      id: id ?? this.id,
      idNhanVienCongTrinh: idNhanVienCongTrinh ?? this.idNhanVienCongTrinh,
      soTien: soTien ?? this.soTien,
      ngayUng: ngayUng ?? this.ngayUng,
      trangThai: trangThai ?? this.trangThai,
      nhanVien: nhanVien ?? this.nhanVien,
      nhanVienCongTrinh: nhanVienCongTrinh ?? this.nhanVienCongTrinh,
      lyDo: lyDo ?? this.lyDo,
    );
  }
}

// Theo danh sách nhân viên

class UngLuongItem{
  double soTien;
  DateTime? ngayUng;
  String? lyDo;
  UngLuongItem({
    required this.soTien,
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
    this.daDoiTru
  });
  double get tongUng {
    return daUngs.fold(
      0.0,
          (sum, item) => sum! + item.soTien,
    ) ?? 0.0;
  }
  double? daDoiTru;
}