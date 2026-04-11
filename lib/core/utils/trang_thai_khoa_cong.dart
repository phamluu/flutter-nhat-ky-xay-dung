
enum TrangThaiKhoaChamCong {
  chuakhoa(0, "Chưa khoá"),
  dakhoa(1, "Đã khóa");
  final int value;
  final String label;
  const TrangThaiKhoaChamCong(this.value, this.label);

  static TrangThaiKhoaChamCong fromValue(int? value) {
    switch (value) {
      case 0:
        return TrangThaiKhoaChamCong.chuakhoa;
      case 1:
        return TrangThaiKhoaChamCong.dakhoa;
      default:
        return TrangThaiKhoaChamCong.chuakhoa;
    }
  }
}