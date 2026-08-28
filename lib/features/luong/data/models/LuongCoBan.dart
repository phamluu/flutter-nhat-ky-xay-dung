import 'package:nhat_ky_xay_dung/features/nhan_vien/data/models/NhanVien.dart';

import '../../../../data/tables/luong_co_ban_table.dart';
class Luongcoban {
  final int? id;
  final int? idNhanVien;
  final double? mucLuong;
  final DateTime? ngayTao;
  final String? ngayApDung;
  final NhanVien? nhanVien;
  final String? ghiChu;
  final int? isSynced;

  Luongcoban({
    this.id,
    this.idNhanVien,
    this.mucLuong,
    this.ngayTao,
    this.ngayApDung,
    this.nhanVien,
    this.ghiChu,
    this.isSynced
  });

  Map<String, dynamic> toMap() {
    final map = {
      LuongCoBanTable.id: id,
      LuongCoBanTable.idNhanVien: idNhanVien,
      LuongCoBanTable.mucLuong: mucLuong,
      LuongCoBanTable.ngayApDung: ngayApDung,
      LuongCoBanTable.ngayTao: (ngayTao ?? DateTime.now()).toIso8601String(),
      LuongCoBanTable.ghiChu: ghiChu
    };
    return map;
  }

  factory Luongcoban.fromMap(Map<String, dynamic> map, {List<NhanVien>? nhanViens}) {
    NhanVien? nv;
    if (nhanViens != null) {
      nv = nhanViens.firstWhere(
            (e) => e.id == map[LuongCoBanTable.idNhanVien],
        orElse: () => NhanVien(id: map[LuongCoBanTable.idNhanVien], hoTen: "Không tên"),
      );
    }

    return Luongcoban(
      id: map[LuongCoBanTable.id],
      idNhanVien: map[LuongCoBanTable.idNhanVien],
      mucLuong: map[LuongCoBanTable.mucLuong],
      ngayTao: map[LuongCoBanTable.ngayTao] != null ? DateTime.parse(map[LuongCoBanTable.ngayTao]) : null,
      ngayApDung: map[LuongCoBanTable.ngayApDung],
      ghiChu: map[LuongCoBanTable.ghiChu],
      nhanVien: nv,
    );
  }

  Luongcoban copyWith({
    int? id,
    required int idNhanVien,
    double? mucLuong,
    DateTime? ngayTao,
    String? ngayApDung,
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
    final homNay = DateTime.now();
    final ngayHienTai =
        '${homNay.year.toString().padLeft(4, '0')}-'
        '${homNay.month.toString().padLeft(2, '0')}-'
        '${homNay.day.toString().padLeft(2, '0')}';
    Luongcoban? latestLuong;
    for (final luong in luongCoBans) {
      final ngayApDung = luong.ngayApDung;
      if (ngayApDung == null || ngayApDung.isEmpty) {
        latestLuong ??= luong;
        continue;
      }
      if (ngayApDung.compareTo(ngayHienTai) > 0) {
        continue;
      }
      if (latestLuong == null ||
          latestLuong.ngayApDung == null ||
          ngayApDung.compareTo(latestLuong.ngayApDung!) > 0) {
        latestLuong = luong;
      }
    }
    return latestLuong?.mucLuong ?? 0;
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

class LuongCoBanModel {
  int idNhanVien;
  final String? hoTen;
  final String? chucVu;
  final double? luongHienTai;
  final String? soDienThoai;
  final String? ngaySinh;
  LuongCoBanModel({
    required this.idNhanVien,
    this.hoTen,
    this.chucVu,
    this.luongHienTai,
    this.soDienThoai,
    this.ngaySinh
  });
}

class LuongCoBanNhanVienModel{
  int id;
  double? soTien;
  DateTime? ngayApDung;
  String? ghiChu;
  LuongCoBanNhanVienModel({
    required this.id,
    this.soTien,
    this.ngayApDung,
    this.ghiChu
  });
}