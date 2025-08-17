class ChamCong {
  int? id;
  int idNhanVienCongTrinh;
  String ngay;
  int? trangThaiSang;   // 0: vắng, 1: có mặt
  int? trangThaiChieu;
  String? ghiChu;

  ChamCong({
    this.id,
    required this.idNhanVienCongTrinh,
    required this.ngay,
    this.trangThaiSang,
    this.trangThaiChieu,
    this.ghiChu,
  });

  factory ChamCong.fromMap(Map<String, dynamic> map) => ChamCong(
    id: map['id'] as int?,
    idNhanVienCongTrinh: map['idNhanVienCongTrinh'] as int,
    ngay: map['ngay'] as String,
    trangThaiSang: map['trangThaiSang'] as int?,
    trangThaiChieu: map['trangThaiChieu'] as int?,
    ghiChu: map['ghiChu'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'idNhanVienCongTrinh': idNhanVienCongTrinh,
    'ngay': ngay,
    'trangThaiSang': trangThaiSang,
    'trangThaiChieu': trangThaiChieu,
    'ghiChu': ghiChu,
  };
}
