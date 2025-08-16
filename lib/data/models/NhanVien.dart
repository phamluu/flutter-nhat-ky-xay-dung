class NhanVien {
  final int? id;
  final String? hoTen;
  final String? email;
  final String? soDienThoai;
  final String? hinhAnh;
  final String? diaChi;
  final String? ngaySinh;
  final int? userId;

  NhanVien({
    this.id,
    this.hoTen,
    this.email,
    this.soDienThoai,
    this.hinhAnh,
    this.diaChi,
    this.ngaySinh,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ho_ten': hoTen,
      'email': email,
      'so_dien_thoai': soDienThoai,
      'hinh_anh': hinhAnh,
      'dia_chi': diaChi,
      'ngay_sinh': ngaySinh,
      'user_id': userId,
    };
  }

  factory NhanVien.fromMap(Map<String, dynamic> map) {
    return NhanVien(
      id: map['id'],
      hoTen: map['ho_ten'],
      email: map['email'],
      soDienThoai: map['so_dien_thoai'],
      hinhAnh: map['hinh_anh'],
      diaChi: map['dia_chi'],
      ngaySinh: map['ngay_sinh'],
      userId: map['user_id'],
    );
  }

  NhanVien copyWith({
    int? id,
    String? hoTen,
    String? email,
    String? soDienThoai,
    String? hinhAnh,
    String? diaChi,
    String? ngaySinh,
    int? userId,
  }) {
    return NhanVien(
      id: id ?? this.id,
      hoTen: hoTen ?? this.hoTen,
      email: email ?? this.email,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      hinhAnh: hinhAnh ?? this.hinhAnh,
      diaChi: diaChi ?? this.diaChi,
      ngaySinh: ngaySinh ?? this.ngaySinh,
      userId: userId ?? this.userId,
    );
  }
}
