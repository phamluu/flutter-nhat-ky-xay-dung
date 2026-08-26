enum LoaiTongUngLuong {
  tatCa,
  chuaDoiTru,
  daDoiTru,
}

enum TrangThaiUngLuong {
  chuaTru(0, 'Chưa trừ'),
  daTru(1, 'Đã trừ');

  final int value;
  final String label;

  const TrangThaiUngLuong(this.value, this.label);

  // Chuyển từ giá trị int (trong Database) sang Enum
  factory TrangThaiUngLuong.fromInt(int value) {
    return TrangThaiUngLuong.values.firstWhere(
          (e) => e.value == value,
      orElse: () => TrangThaiUngLuong.chuaTru,
    );
  }
}