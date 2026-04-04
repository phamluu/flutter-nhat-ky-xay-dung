// Lương theo công trình
class BangLuong {
  int idCongTrinh;
  int idNhanVienCongTrinh;
  String? hoTen;
  double? tongSoCong;
  double? tongLuong;
  double? ungLuong;
  double? thucNhan;
  int thang;
  int nam;
  int? trangThai;
  BangLuong({
    required this.idCongTrinh,
    required this.idNhanVienCongTrinh,
    this.hoTen,
    this.tongSoCong,
    this.tongLuong,
    this.ungLuong,
    this.thucNhan,
    this.trangThai,
    required this.thang,
    required this.nam
  });
}