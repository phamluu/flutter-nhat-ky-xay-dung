import 'package:nhat_ky_xay_dung/data/models/NhanVien.dart';

class Luongcoban {
  final int? id;
  final int idNhanVien;
  final double? mucLuong;
  final DateTime ngayTao;
  final DateTime? ngayApDung;
  final NhanVien? nhanVien;
  final String? ghiChu;

  Luongcoban({
    this.id,
    required this.idNhanVien,
    this.mucLuong,
    required this.ngayTao,
    this.ngayApDung,
    this.nhanVien,
    this.ghiChu,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'idNhanVien': idNhanVien,
      'mucLuong': mucLuong,
      'ngayApDung': ngayApDung?.toIso8601String(),
      'ngayTao': ngayTao,
      'ghiChu': ghiChu
    };
    if (nhanVien != null) {
      map['nhan_vien'] = nhanVien!.toMap();
    }
    return map;
  }


  factory Luongcoban.fromMap(Map<String, dynamic> map, {NhanVien? nhanVien}) {
    return Luongcoban(
      id: map['id'],
      idNhanVien: map['idNhanVien'],
      ghiChu: map['ghiChu'],
      ngayTao: DateTime.parse(map['ngayTao']),
      ngayApDung: DateTime.parse(map['ngayApDung']),
      mucLuong: map['mucLuong']
    );
  }

  Luongcoban copyWith({
    int? id,
    required int idNhanVien,
    double? mucLuong,
    required DateTime ngayTao,
    DateTime? ngayApDung,
    NhanVien? nhanVien,
    String? ghiChu,
  }) {
    return Luongcoban(
      id: id ?? this.id,
      idNhanVien: idNhanVien ?? this.idNhanVien,
      ghiChu: ghiChu ?? this.ghiChu,
      ngayTao: ngayTao ?? this.ngayTao,
      ngayApDung: ngayApDung ?? this.ngayApDung,
      nhanVien: nhanVien ?? this.nhanVien, // gán
    );
  }
}
