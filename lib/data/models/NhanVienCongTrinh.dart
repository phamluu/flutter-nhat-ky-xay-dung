import 'package:nhat_ky_xay_dung/data/models/NhanVien.dart';

import 'CongTrinh.dart';

class NhanVienCongTrinh {
  int? id;
  int idNhanVien;
  int? idCongTrinh; // có thể null
  String? ngayBatDau; // lưu theo ISO string
  String? ngayKetThuc;
  String? vaiTro;
  final CongTrinh? congTrinh;
  final NhanVien? nhanVien;
  NhanVienCongTrinh({
    this.id,
    required this.idNhanVien,
    this.idCongTrinh,
    this.ngayBatDau,
    this.ngayKetThuc,
    this.vaiTro,
    this.congTrinh,
    this.nhanVien
  });

  // Chuyển từ Map (SQLite) sang object
  factory NhanVienCongTrinh.fromMap(Map<String, dynamic> map, {CongTrinh? congTrinh, NhanVien? nhanVien}) {
    return NhanVienCongTrinh(
      id: map['id'] as int?,
      idNhanVien: map['idNhanVien'] as int,
      idCongTrinh: map['idCongTrinh'] as int?,
      ngayBatDau: map['ngayBatDau'] as String?,
      ngayKetThuc: map['ngayKetThuc'] as String?,
      vaiTro: map['vaiTro'] as String?,
      congTrinh: congTrinh,
      nhanVien: nhanVien
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
    if (congTrinh != null) {
      map['cong_trinh'] = congTrinh!.toMap();
    }
    if (nhanVien != null) {
      map['nhan_vien'] = nhanVien!.toMap();
    }
    if (id != null) map['id'] = id;
    return map;
  }
}
