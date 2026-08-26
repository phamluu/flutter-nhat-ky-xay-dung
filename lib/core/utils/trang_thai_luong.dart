enum TrangThaiChiLuong{
  chuaChi(0, "Chưa chi"),
  chi1Phan(1, "Đã chi 1 phần"),
  daChi(2, "Đã chi đủ");
  final int value;
  final String label;
  const TrangThaiChiLuong(this.value, this.label);
  static TrangThaiChiLuong fromValue(int? value){
    switch (value){
      case 0:
        return TrangThaiChiLuong.chuaChi;
      case 1:
        return TrangThaiChiLuong.chi1Phan;
      case 2:
        return TrangThaiChiLuong.daChi;
        default:
          return TrangThaiChiLuong.chuaChi;
    }
  }
}
enum TrangThaiLuong {
  chuachot(0, "Chưa chốt"),
  dachot(1, "Đã chốt");
  final int value;
  final String label;

  const TrangThaiLuong(this.value, this.label);

  /// 🔹 convert từ int → enum
  static TrangThaiLuong fromValue(int? value) {
    switch (value) {
      case 1:
        return TrangThaiLuong.dachot;
      case 0:
        return TrangThaiLuong.chuachot;
      default:
        return TrangThaiLuong.chuachot;
    }
  }
}