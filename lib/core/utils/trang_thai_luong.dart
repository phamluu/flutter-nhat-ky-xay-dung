
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