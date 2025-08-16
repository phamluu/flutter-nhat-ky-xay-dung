class NhanVienCongTrinh {
  int? id;
  int idNhanVien;
  int? idCongTrinh; // có thể null
  String? ngayBatDau; // lưu theo ISO string
  String? ngayKetThuc;
  String? vaiTro;

  NhanVienCongTrinh({
    this.id,
    required this.idNhanVien,
    this.idCongTrinh,
    this.ngayBatDau,
    this.ngayKetThuc,
    this.vaiTro,
  });

  // Chuyển từ Map (SQLite) sang object
  factory NhanVienCongTrinh.fromMap(Map<String, dynamic> map) {
    return NhanVienCongTrinh(
      id: map['id'] as int?,
      idNhanVien: map['idNhanVien'] as int,
      idCongTrinh: map['idCongTrinh'] as int?,
      ngayBatDau: map['ngayBatDau'] as String?,
      ngayKetThuc: map['ngayKetThuc'] as String?,
      vaiTro: map['vaiTro'] as String?,
    );
  }

  // Chuyển từ object sang Map để lưu vào SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'idNhanVien': idNhanVien,
      'idCongTrinh': idCongTrinh,
      'ngayBatDau': ngayBatDau,
      'ngayKetThuc': ngayKetThuc,
      'vaiTro': vaiTro,
    };
    if (id != null) map['id'] = id;
    return map;
  }
}
