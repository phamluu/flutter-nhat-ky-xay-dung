class LuongCoBanModel {
  int idNhanVien;
  final String? hoTen;
  final String? chucVu;
  final double? luongHienTai;
  final String? soDienThoai;
  final String? ngaySinh;
  LuongCoBanModel({
    required this.idNhanVien,
    this.hoTen,
    this.chucVu,
    this.luongHienTai,
    this.soDienThoai,
    this.ngaySinh
  });
}

class LuongCoBanNhanVienModel{
  int id;
  double? soTien;
  DateTime? ngayApDung;
  String? ghiChu;
  LuongCoBanNhanVienModel({
    required this.id,
    this.soTien,
    this.ngayApDung,
    this.ghiChu
});
}