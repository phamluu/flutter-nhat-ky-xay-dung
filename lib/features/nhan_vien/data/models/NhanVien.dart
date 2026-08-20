import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_table.dart';

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
      NhanVienTable.id: id,
      NhanVienTable.hoTen: hoTen,
      NhanVienTable.email: email,
      NhanVienTable.soDienThoai: soDienThoai,
      NhanVienTable.hinhAnh: hinhAnh,
      NhanVienTable.diaChi: diaChi,
      NhanVienTable.ngaySinh: ngaySinh?.toIso8601String(),
      NhanVienTable.userId: userId,
      NhanVienTable.serverId: server_id
    };
  }

  // Lấy dữ liệu từ db local
  factory NhanVien.fromMap(Map<String, dynamic> map) {
    return NhanVien(
        id: map[NhanVienTable.id],
        hoTen: map[NhanVienTable.hoTen],
        email: map[NhanVienTable.email],
        soDienThoai: map[NhanVienTable.soDienThoai],
        hinhAnh: map[NhanVienTable.hinhAnh],
        diaChi: map[NhanVienTable.diaChi],
        ngaySinh: map[NhanVienTable.ngaySinh] != null
            ? DateTime.tryParse(map[NhanVienTable.ngaySinh])
            : null,
        userId: map[NhanVienTable.userId],
        isSynced: map[NhanVienTable.isSynced],
        server_id: map[NhanVienTable.serverId],
        is_deleted: map[NhanVienTable.isDeleted]
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
