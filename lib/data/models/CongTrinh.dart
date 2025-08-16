class CongTrinh {
  final int? id;           // Khóa chính
  final String ten;        // Tên công trình
  final String? diaChi;    // Địa chỉ
  final String? moTa;      // Mô tả chi tiết
  final String? ngayBatDau; // yyyy-MM-dd
  final String? ngayKetThuc; // yyyy-MM-dd (có thể null)

  CongTrinh({
    this.id,
    required this.ten,
    this.diaChi,
    this.moTa,
    this.ngayBatDau,
    this.ngayKetThuc,
  });

  /// Convert object -> Map (dùng để insert/update vào SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ten': ten,
      'dia_chi': diaChi,
      'mo_ta': moTa,
      'ngay_bat_dau': ngayBatDau,
      'ngay_ket_thuc': ngayKetThuc,
    };
  }

  /// Convert Map -> object (dùng khi đọc từ SQLite)
  factory CongTrinh.fromMap(Map<String, dynamic> map) {
    return CongTrinh(
      id: map['id'],
      ten: map['ten'],
      diaChi: map['dia_chi'],
      moTa: map['mo_ta'],
      ngayBatDau: map['ngay_bat_dau'],
      ngayKetThuc: map['ngay_ket_thuc'],
    );
  }
  // 👉 Thêm copyWith ở đây
  CongTrinh copyWith({
    int? id,
    String? ten,
    String? diaChi,
    String? moTa,
    String? ngayBatDau,
    String? ngayKetThuc,
  }) {
    return CongTrinh(
      id: id ?? this.id,
      ten: ten ?? this.ten,
      diaChi: diaChi ?? this.diaChi,
      moTa: moTa ?? this.moTa,
      ngayBatDau: ngayBatDau ?? this.ngayBatDau,
      ngayKetThuc: ngayKetThuc ?? this.ngayKetThuc,
    );
  }
}
