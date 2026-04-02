class CongTrinh {
  final int? id;           // Khóa chính
  final String ten;        // Tên công trình
  final String? diaChi;    // Địa chỉ
  final String? moTa;      // Mô tả chi tiết
  final String? ngayBatDau; // yyyy-MM-dd
  final String? ngayKetThuc; // yyyy-MM-dd (có thể null)
  final String? hinhAnh;
  final double? tienDo;
  final String? ngayTao;
  CongTrinh({
    this.id,
    required this.ten,
    this.diaChi,
    this.moTa,
    this.ngayBatDau,
    this.ngayKetThuc,
    this.hinhAnh,
    this.tienDo,
    this.ngayTao
  });

  /// Convert object -> Map (dùng để insert/update vào SQLite)
  Map<String, dynamic> toMapInsert() {
    return {
      'ten': ten,
      'dia_chi': diaChi,
      'mo_ta': moTa,
      'ngay_bat_dau': ngayBatDau,
      'ngay_ket_thuc': ngayKetThuc,
      'hinh_anh': hinhAnh,
      'ngay_tao': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> toMapUpdate() {
    return {
      'ten': ten,
      'dia_chi': diaChi,
      'mo_ta': moTa,
      'ngay_bat_dau': ngayBatDau,
      'ngay_ket_thuc': ngayKetThuc,
      'hinh_anh': hinhAnh,
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
      hinhAnh: map['hinh_anh'],
      ngayTao: map['ngay_tao']
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
    String? hinhAnh,
    String? ngayTao,
  }) {
    return CongTrinh(
      id: id ?? this.id,
      ten: ten ?? this.ten,
      diaChi: diaChi ?? this.diaChi,
      moTa: moTa ?? this.moTa,
      ngayBatDau: ngayBatDau ?? this.ngayBatDau,
      ngayKetThuc: ngayKetThuc ?? this.ngayKetThuc,
      hinhAnh: hinhAnh?? this.hinhAnh,
      ngayTao: ngayTao ?? this.ngayTao
    );
  }
}
