
enum TrangThaiTienDo {
  chualam(0, "Chưa làm"),
  danglam(1, "Đang làm"),
  hoangthanh(2, "Hooàn thành");
  final int value;
  final String label;

  const TrangThaiTienDo(this.value, this.label);

  /// 🔹 convert từ int → enum
  static TrangThaiTienDo fromValue(int? value) {
    switch (value) {
      case 0:
        return TrangThaiTienDo.chualam;
      case 1:
        return TrangThaiTienDo.danglam;
      case 2:
        return TrangThaiTienDo.hoangthanh;
      default:
        return TrangThaiTienDo.chualam;
    }
  }
}