import 'package:nhat_ky_xay_dung/features/nhan_vien/data/models/NhanVien.dart';
import 'package:nhat_ky_xay_dung/features/nhan_vien_cong_trinh/data/models/NhanVienCongTrinh.dart';

class ChamCong {
  int? id;
  int idNhanVienCongTrinh;
  String ngay;
  int? trangThaiSang;   // 0: vắng, 1: có mặt
  int? trangThaiChieu;
  String? ghiChu;
  NhanVienCongTrinh? nhanVienCongTrinh;
  final int? isSynced;
  ChamCong({
    this.id,
    required this.idNhanVienCongTrinh,
    required this.ngay,
    this.trangThaiSang,
    this.trangThaiChieu,
    this.ghiChu,
    this.nhanVienCongTrinh,
    this.isSynced
  });

  factory ChamCong.fromMap(Map<String, dynamic> map) => ChamCong(
    id: map['id'] as int?,
    idNhanVienCongTrinh: map['id_nhan_vien_cong_trinh'] as int,
    ngay: map['ngay'] ?? '',
    trangThaiSang: map['trang_thai_sang'] as int?,
    trangThaiChieu: map['trang_thai_chieu'] as int?,
    ghiChu: map['ghi_chu'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'id_nhan_vien_cong_trinh': idNhanVienCongTrinh,
    'ngay': ngay,
    'trang_thai_sang': trangThaiSang,
    'trang_thai_chieu': trangThaiChieu,
    'ghi_chu': ghiChu,
    'ngay_tao': DateTime.now().toIso8601String(),
  };
}
