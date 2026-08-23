import 'package:nhat_ky_xay_dung/data/tables/nhan_vien_table.dart';
import 'package:nhat_ky_xay_dung/features/nhan_vien/data/models/NhanVien.dart';

import '../../../../data/tables/nhan_vien_cong_trinh_table.dart';
import 'CongTrinh.dart';

class NhanVienCongTrinh {
  int? id;
  int idNhanVien;
  String? tenNhanVien;
  String? soDienThoai;
  int? idCongTrinh; // có thể null
  String? ngayBatDau; // lưu theo ISO string
  String? ngayKetThuc;
  String? vaiTro;
  final CongTrinh? congTrinh;
  final NhanVien? nhanVien;
  final int? isSynced;
  NhanVienCongTrinh({
    this.id,
    required this.idNhanVien,
    this.tenNhanVien,
    this.soDienThoai,
    this.idCongTrinh,
    this.ngayBatDau,
    this.ngayKetThuc,
    this.vaiTro,
    this.congTrinh,
    this.nhanVien,
    this.isSynced
  });

  // Chuyển từ Map (SQLite) sang object
  // factory NhanVienCongTrinh.fromMap2( Map<String, dynamic> map, { CongTrinh? congTrinh, NhanVien? nhanVien,}) {
  //   // Lấy tên nhân viên từ SQL JOIN (alias ten_nhan_vien hoặc ho_ten)
  //   final tenFromSql = (map['ten_nhan_vien'] as String?) ?? (map['ho_ten'] as String?);
  //   // Nếu tham số nhanVien chưa truyền vào nhưng SQL có trả về tên, tự tạo Object NhanVien
  //   final resolvedNhanVien = nhanVien ??
  //       (tenFromSql != null
  //           ? NhanVien(
  //         id: (map['idNhanVien'] ?? map['id_nhan_vien']) as int? ?? 0,
  //         hoTen: tenFromSql,
  //       )
  //           : null);
  //   return NhanVienCongTrinh(
  //     id: map['id'] as int?,
  //     idNhanVien: (map['idNhanVien'] ?? map['id_nhan_vien']) as int? ?? 0,
  //     idCongTrinh: (map['idCongTrinh'] ?? map['id_cong_trinh']) as int?,
  //     ngayBatDau: (map['ngayBatDau'] ?? map['ngay_bat_dau']) as String?,
  //     ngayKetThuc: (map['ngayKetThuc'] ?? map['ngay_ket_thuc']) as String?,
  //     vaiTro: (map['vaiTro'] ?? map['vai_tro']) as String?,
  //     congTrinh: congTrinh,
  //     nhanVien: resolvedNhanVien,
  //   );
  // }
  factory NhanVienCongTrinh.fromMap(Map<String, dynamic> map) {
    return NhanVienCongTrinh(
        id: map[NhanVienCongTrinhTable.id] as int?,
        idNhanVien: map[NhanVienCongTrinhTable.idNhanVien] as int,
        idCongTrinh: map[NhanVienCongTrinhTable.idCongTrinh] as int?,
        ngayBatDau: map[NhanVienCongTrinhTable.ngayBatDau] as String?,
        ngayKetThuc: map[NhanVienCongTrinhTable.ngayKetThuc] as String?,
        vaiTro: map[NhanVienCongTrinhTable.vaiTro] as String?,
        tenNhanVien: map[NhanVienTable.hoTen] as String?,
        soDienThoai: map[NhanVienTable.soDienThoai] as String?

    );
  }
  // factory NhanVienCongTrinh.fromMap(Map<String, dynamic> map, {CongTrinh? congTrinh, NhanVien? nhanVien}) {
  //   return NhanVienCongTrinh(
  //     id: map['id'] as int?,
  //     idNhanVien: map['idNhanVien'] as int,
  //     idCongTrinh: map['idCongTrinh'] as int?,
  //     ngayBatDau: map['ngayBatDau'] as String?,
  //     ngayKetThuc: map['ngayKetThuc'] as String?,
  //     vaiTro: map['vaiTro'] as String?,
  //     congTrinh: congTrinh,
  //     nhanVien: nhanVien
  //   );
  // }

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
      map['cong_trinh'] = congTrinh!.toMapUpdate();
    }
    if (nhanVien != null) {
      map['nhan_vien'] = nhanVien!.toMap();
    }
    if (id != null) map['id'] = id;
    return map;
  }

  // 👉 Đặt đoạn này ở cuối class
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is NhanVienCongTrinh &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}
