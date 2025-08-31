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
    final map = <String, dynamic>{
      'id': id,
      'idNhanVien': idNhanVien,
      'idNhanVienCongTrinh': idNhanVienCongTrinh,
      'soTien': soTien,
      'ngayUng': ngayUng?.toIso8601String(),
      'lyDo': lyDo,
    };
    return map;
  }

  factory Ungluong.fromMap(
      Map<String, dynamic> map, {
        List<NhanVien>? nhanViens,
        List<NhanVienCongTrinh>? nhanVienCongTrinhs,
        NhanVienCongTrinh? nvct,
      }) {
    // lấy nhân viên
    NhanVien? nv;
    if (nhanViens != null) {
      nv = nhanViens.firstWhere(
            (e) => e.id == (map['idNhanVien'] as int?),
        orElse: () => NhanVien(
          id: map['idNhanVien'] as int?,
          hoTen: "Không tên",
        ),
      );
    }

    // lấy nhân viên công trình
    if (nhanVienCongTrinhs != null) {
      nvct = nhanVienCongTrinhs.firstWhere(
            (e) => e.id == (map['idNhanVienCongTrinh'] as int?),
        orElse: () => NhanVienCongTrinh(
          id: map['idNhanVienCongTrinh'] as int?,
          idNhanVien: map['idNhanVien'] as int,
          idCongTrinh: map['idCongTrinh'] as int?, // cần có cột này khi query
        ),
      );
    }

    return Ungluong(
      id: map['id'] as int?,
      idNhanVien: map['idNhanVien'] as int,
      idNhanVienCongTrinh: map['idNhanVienCongTrinh'] as int?,
      soTien: (map['soTien'] is int)
          ? (map['soTien'] as int).toDouble()
          : map['soTien'] as double?,
      ngayUng: map['ngayUng'] != null
          ? DateTime.tryParse(map['ngayUng'].toString())
          : null,
      lyDo: map['lyDo'] as String?,
      nhanVien: nv,
      nhanVienCongTrinh: nvct,
    );
  }

  Ungluong copyWith({
    int? id,
    int? idNhanVien,
    int? idNhanVienCongTrinh,
    double? soTien,
    DateTime? ngayUng,
    NhanVien? nhanVien,
    NhanVienCongTrinh? nhanVienCongTrinh,
    String? lyDo,
  }) {
    return Ungluong(
      id: id ?? this.id,
      idNhanVien: idNhanVien ?? this.idNhanVien,
      idNhanVienCongTrinh: idNhanVienCongTrinh ?? this.idNhanVienCongTrinh,
      soTien: soTien ?? this.soTien,
      ngayUng: ngayUng ?? this.ngayUng,
      nhanVien: nhanVien ?? this.nhanVien,
      nhanVienCongTrinh: nhanVienCongTrinh ?? this.nhanVienCongTrinh,
      lyDo: lyDo ?? this.lyDo,
    );
  }
}
