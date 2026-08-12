class NhanVien {
  final int? id;
  final String? hoTen;
  final String? email;
  final String? soDienThoai;
  final String? hinhAnh;
  final String? diaChi;
  final DateTime? ngaySinh;
  final String? userId;
  int? isSynced;
  String? server_id;
  final int? is_deleted;
  NhanVien({
    this.id,
    this.hoTen,
    this.email,
    this.soDienThoai,
    this.hinhAnh,
    this.diaChi,
    this.ngaySinh,
    this.userId,
    this.isSynced,
    this.server_id,
    this.is_deleted
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is NhanVien && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  // Lấy dữ liệu ra ngoài truyền cho api
  Map<String, dynamic> toApi() {
    return {
      'HoTen': hoTen,
      'Email': email,
      'SoDienThoai': soDienThoai,
      'HinhAnh': hinhAnh,
      'DiaChi': diaChi,
      'NgaySinh': ngaySinh?.toIso8601String(),
    };
  }
  // Để insert, update local
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ho_ten': hoTen,
      'email': email,
      'so_dien_thoai': soDienThoai,
      'hinh_anh': hinhAnh,
      'dia_chi': diaChi,
      'ngay_sinh': ngaySinh?.toIso8601String(),
      'user_id': userId,
      'server_id': server_id
    };
  }

  // Lấy dữ liệu từ db local
  factory NhanVien.fromMap(Map<String, dynamic> map) {
    return NhanVien(
        id: map['id'],
        hoTen: map['ho_ten'],
        email: map['email'],
        soDienThoai: map['so_dien_thoai'],
        hinhAnh: map['hinh_anh'],
        diaChi: map['dia_chi'],
        ngaySinh: map['ngay_sinh'] != null
            ? DateTime.tryParse(map['ngay_sinh'])
            : null,
        userId: map['user_id'],
        isSynced: map['is_synced'],
        server_id: map['server_id'],
        is_deleted: map['is_deleted']
    );
  }

  NhanVien copyWith({
    int? id,
    String? hoTen,
    String? email,
    String? soDienThoai,
    String? hinhAnh,
    String? diaChi,
    DateTime? ngaySinh,
    String? userId,
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
