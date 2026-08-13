import 'package:nhat_ky_xay_dung/features/nhan_vien/data/models/NhanVien.dart';

class Luongcoban {
  final int? id;
  final int idNhanVien;
  final double? mucLuong;
  final DateTime? ngayTao;
  final DateTime? ngayApDung;
  final NhanVien? nhanVien;
  final String? ghiChu;
  final int? isSynced;

  Luongcoban({
    this.id,
    required this.idNhanVien,
    this.mucLuong,
    this.ngayTao,
    this.ngayApDung,
    this.nhanVien,
    this.ghiChu,
    this.isSynced
  });

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'idNhanVien': idNhanVien,
      'mucLuong': mucLuong,
      'ngayApDung': ngayApDung?.toIso8601String(),
      'ngayTao': (ngayTao ?? DateTime.now()).toIso8601String(),
      'ghiChu': ghiChu
    };
    return map;
  }

  factory Luongcoban.fromMap(Map<String, dynamic> map, {List<NhanVien>? nhanViens}) {
    NhanVien? nv;
    if (nhanViens != null) {
      nv = nhanViens.firstWhere(
            (e) => e.id == map['idNhanVien'],
        orElse: () => NhanVien(id: map['idNhanVien'], hoTen: "Không tên"),
      );
    }

    return Luongcoban(
      id: map['id'],
      idNhanVien: map['idNhanVien'],
      mucLuong: map['mucLuong'],
      ngayTao: map['ngayTao'] != null ? DateTime.parse(map['ngayTao']) : null,
      ngayApDung: map['ngayApDung'] != null ? DateTime.parse(map['ngayApDung']) : null,
      ghiChu: map['ghiChu'],
      nhanVien: nv,
    );
  }

  Luongcoban copyWith({
    int? id,
    required int idNhanVien,
    double? mucLuong,
    DateTime? ngayTao,
    DateTime? ngayApDung,
    NhanVien? nhanVien,
    String? ghiChu,
  }) {
    return Luongcoban(
      id: id ?? this.id,
      idNhanVien: idNhanVien ?? this.idNhanVien,
      mucLuong: mucLuong ?? this.mucLuong,
      ghiChu: ghiChu ?? this.ghiChu,
      ngayTao: ngayTao ?? this.ngayTao,
      ngayApDung: ngayApDung ?? this.ngayApDung,
      nhanVien: nhanVien ?? this.nhanVien, // gán
    );
  }
}

class LuongCoBanViewModel{
  List<LuongNhanVienViewModel> luongNhanViens = [];
}
class LuongNhanVienViewModel{
  late NhanVien nhanVien;
  late List<Luongcoban> luongCoBans;

  double get mucLuongHienTai {
    if (luongCoBans.isEmpty) return 0;
    Luongcoban latestLuong = luongCoBans.reduce((a, b) {
      if (a.ngayApDung == null) return b;
      if (b.ngayApDung == null) return a;
      return a.ngayApDung!.isAfter(b.ngayApDung!) ? a : b;
    });
    return latestLuong.mucLuong ?? 0;
  }
  int get soLanTangLuong {
    if (luongCoBans.length <= 1) return 0;
    List<Luongcoban> sorted = List.from(luongCoBans)
      ..sort((a, b) {
        if (a.ngayApDung == null) return -1;
        if (b.ngayApDung == null) return 1;
        return a.ngayApDung!.compareTo(b.ngayApDung!);
      });

    int count = 0;
    for (int i = 1; i < sorted.length; i++) {
      double prev = sorted[i - 1].mucLuong ?? 0;
      double curr = sorted[i].mucLuong ?? 0;
      if (curr > prev) count++;
    }
    return count;
  }
}