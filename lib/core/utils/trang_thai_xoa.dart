
enum TrangThaiXoa {
  chuaxoa(0, "Chưa xóa"),
  daxoa(1, "Đã xóa");
  final int value;
  final String label;

  const TrangThaiXoa(this.value, this.label);

  /// 🔹 convert từ int → enum
  static TrangThaiXoa fromValue(int? value) {
    switch (value) {
      case 0:
        return TrangThaiXoa.chuaxoa;
      case 1:
        return TrangThaiXoa.daxoa;
      default:
        return TrangThaiXoa.chuaxoa;
    }
  }
}