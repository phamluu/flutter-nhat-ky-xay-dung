import 'CongTrinh.dart';

class NhatKy {
  final int? id;
  final String? tenNhatKy;
  final String? noiDung;
  final String ngayTao;
  final String? ngayTrienKhai;
  final int idCongTrinh;
  final CongTrinh? congTrinh;
  final int? trangThai;
  final int? thoiTietSang;
  final int? thoiTietChieu;

  NhatKy({
    this.id,
    this.tenNhatKy,
    this.noiDung,
    required this.ngayTao,
    this.ngayTrienKhai,
    required this.idCongTrinh,
    this.congTrinh,
    this.trangThai,
    this.thoiTietSang,
    this.thoiTietChieu,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'ten_nhat_ky': tenNhatKy,
      'noi_dung': noiDung,
      'ngay_tao': ngayTao,
      'ngay_trien_khai': ngayTrienKhai,
      'id_cong_trinh': idCongTrinh,
      'trang_thai': trangThai,
      'thoi_tiet_sang': thoiTietSang,
      'thoi_tiet_chieu': thoiTietChieu,
    };
    if (congTrinh != null) {
      map['cong_trinh'] = congTrinh!.toMap();
    }
    return map;
  }


  factory NhatKy.fromMap(Map<String, dynamic> map, {CongTrinh? congTrinh}) {
    return NhatKy(
      id: map['id'],
      tenNhatKy: map['ten_nhat_ky'],
      noiDung: map['noi_dung'],
      ngayTao: map['ngay_tao'],
      ngayTrienKhai: map['ngay_trien_khai'],
      idCongTrinh: map['id_cong_trinh'],
      congTrinh: congTrinh,
      trangThai: map['trang_thai'],
      thoiTietSang: map['thoi_tiet_sang'],
      thoiTietChieu: map['thoi_tiet_chieu'],
    );
  }

  NhatKy copyWith({
    int? id,
    String? tenNhatKy,
    String? noiDung,
    String? ngayTao,
    String? ngayTrienKhai,
    int? idCongTrinh,
    CongTrinh? congTrinh,
    int? trangThai,
    int? thoiTietSang,
    int? thoiTietChieu,
  }) {
    return NhatKy(
      id: id ?? this.id,
      tenNhatKy: tenNhatKy ?? this.tenNhatKy,
      noiDung: noiDung ?? this.noiDung,
      ngayTao: ngayTao ?? this.ngayTao,
      ngayTrienKhai: ngayTrienKhai ?? this.ngayTrienKhai,
      idCongTrinh: idCongTrinh ?? this.idCongTrinh,
      congTrinh: congTrinh ?? this.congTrinh, // gán
      trangThai: trangThai ?? this.trangThai,
      thoiTietSang: thoiTietSang ?? this.thoiTietSang,
      thoiTietChieu: thoiTietChieu ?? this.thoiTietChieu,
    );
  }
}
