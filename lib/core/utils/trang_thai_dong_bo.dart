
enum TrangThaiDongBo {
  chuadongbo(0, "Chưa đồng bộ"),
  dadongbo(1, "Đã đồng bộ");
  final int value;
  final String label;

  const TrangThaiDongBo(this.value, this.label);

  /// 🔹 convert từ int → enum
  static TrangThaiDongBo fromValue(int? value) {
    switch (value) {
      case 0:
        return TrangThaiDongBo.chuadongbo;
      case 1:
        return TrangThaiDongBo.dadongbo;
      default:
        return TrangThaiDongBo.chuadongbo;
    }
  }
}