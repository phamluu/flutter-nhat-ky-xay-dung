
import 'package:nhat_ky_xay_dung/data/models/NhanVienCongTrinh.dart';

import 'NhanVien.dart';

class Ungluong {
  final int? id;
  final int idNhanVien;
  final int? idNhanVienCongTrinh;
  final double? soTien;
  final DateTime? ngayUng;
  final NhanVien? nhanVien;
  final NhanVienCongTrinh? nhanVienCongTrinh;
  final String? lyDo;

  Ungluong({
    this.id,
    required this.idNhanVien,
    this.idNhanVienCongTrinh,
    this.soTien,
    this.ngayUng,
    this.nhanVien,
    this.nhanVienCongTrinh,
    this.lyDo,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'idNhanVien': idNhanVien,
      'idNhanVienCongTrinh': idNhanVienCongTrinh,
      'soTien': soTien,
      'ngayUng': ngayUng?.toIso8601String(),
      'lyDo': lyDo
    };
    // if (nhanVien != null) {
    //   map['nhan_vien'] = nhanVien!.toMap();
    // }
    // if (nhanVienCongTrinh != null) {
    //   map['nhan_vien_cong_trinh'] = nhanVienCongTrinh!.toMap();
    // }
    return map;
  }


  factory Ungluong.fromMap(Map<String, dynamic> map, {List<NhanVien>? nhanViens, NhanVienCongTrinh? nhanVienCongTrinh}) {
    NhanVien? nv;
    if (nhanViens != null) {
      nv = nhanViens.firstWhere(
            (e) => e.id == map['idNhanVien'],
        orElse: () => NhanVien(id: map['idNhanVien'], hoTen: "Không tên"),
      );
    }
    return Ungluong(
        id: map['id'],
        idNhanVien: map['idNhanVien'],
        soTien: map['soTien'],
        lyDo: map['lyDo'],
        ngayUng: map['ngayUng'] != null ? DateTime.parse(map['ngayUng']) : null,
        idNhanVienCongTrinh: map['idNhanVienCongTrinh'],
        nhanVien: nv,
    );
  }

  Ungluong copyWith({
    int? id,
    required int idNhanVien,
    int? idNhanVienCongTrinh,
    double? soTien,
    DateTime? ngayUng,
    NhanVien? nhanVien,
    NhanVienCongTrinh? nhanVienCongTrinh,
    String? lyDo
  }) {
    return Ungluong(
      id: id ?? this.id,
      idNhanVien: idNhanVien ?? this.idNhanVien,
      idNhanVienCongTrinh: idNhanVienCongTrinh ?? this.idNhanVienCongTrinh,
      soTien: soTien ?? this.soTien,
      ngayUng: ngayUng ?? this.ngayUng,
      nhanVien: nhanVien ?? this.nhanVien, // gán
      nhanVienCongTrinh: nhanVienCongTrinh ?? this.nhanVienCongTrinh,
      lyDo: lyDo ?? this.lyDo,
    );
  }
}
