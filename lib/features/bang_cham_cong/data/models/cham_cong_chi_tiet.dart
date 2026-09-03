import 'package:nhat_ky_xay_dung/data/tables/cham_cong_chi_tiet_table.dart';

class ChamCongChiTiet {
  int id;
  int idBangChamCong ;             // id bảng chấm công
  int idNhanVienCongTrinh;
  String ngay;
  int? trangThaiSang;
  int? trangThaiChieu;
  String? tangCaBatDau ;
  String? tangCaKetthuc;
  String? ghiChu ;
  int? idPhienChot;
  String? serverId ;
  int? isSynced ;
  String? updatedAt ;
  int? isDeleted ;
  // Load thêm không có trong table
  ChamCongChiTiet({
    required this.id,
    required this.idBangChamCong,
    required this.idNhanVienCongTrinh,
    required this.ngay,
    this.trangThaiSang,
    this.trangThaiChieu,
    this.tangCaBatDau,
    this.tangCaKetthuc,
    this.ghiChu,
    this.idPhienChot,
    this.serverId,
    this.isSynced,
    this.updatedAt,
    this.isDeleted
});
  factory ChamCongChiTiet.fromMap(Map<String, dynamic> map) => ChamCongChiTiet(
    id: map[ChamCongChiTietTable.id] as int,
    idBangChamCong: map[ChamCongChiTietTable.idChamCong] as int,
    idNhanVienCongTrinh: map[ChamCongChiTietTable.idNhanVienCongTrinh] as int,
    ngay: map[ChamCongChiTietTable.ngay] as String,
    trangThaiSang: map[ChamCongChiTietTable.trangThaiSang] as int?,
    trangThaiChieu: map[ChamCongChiTietTable.trangThaiChieu] as int?,
    tangCaBatDau: map[ChamCongChiTietTable.tangCaBatDau] as String?,
    tangCaKetthuc: map[ChamCongChiTietTable.tangCaKetthuc] as String?,
    ghiChu: map[ChamCongChiTietTable.ghiChu] as String?,
    idPhienChot: map[ChamCongChiTietTable.idPhienChot] as int?,
    serverId: map[ChamCongChiTietTable.serverId] as String?,
    isSynced: map[ChamCongChiTietTable.isSynced] as int?,
    updatedAt: map[ChamCongChiTietTable.updatedAt] as String?,
    isDeleted: map[ChamCongChiTietTable.isDeleted] as int?
  );

  Map<String, dynamic> toMapInsert() => {
    ChamCongChiTietTable.idChamCong: idBangChamCong,
    ChamCongChiTietTable.idNhanVienCongTrinh: idNhanVienCongTrinh,
    ChamCongChiTietTable.ngay: ngay,
    ChamCongChiTietTable.trangThaiSang: trangThaiSang,
    ChamCongChiTietTable.trangThaiChieu: trangThaiChieu,
    ChamCongChiTietTable.tangCaBatDau: tangCaBatDau,
    ChamCongChiTietTable.tangCaKetthuc: tangCaKetthuc,
    ChamCongChiTietTable.ghiChu: ghiChu,
    ChamCongChiTietTable.serverId: serverId,
    ChamCongChiTietTable.isSynced: isSynced,
    ChamCongChiTietTable.updatedAt: DateTime.now().toIso8601String(),
    ChamCongChiTietTable.isDeleted: isDeleted
  };
  Map<String, dynamic> toMapUpdate() => {
    ChamCongChiTietTable.trangThaiSang: trangThaiSang,
    ChamCongChiTietTable.trangThaiChieu: trangThaiChieu,
    ChamCongChiTietTable.tangCaBatDau: tangCaBatDau,
    ChamCongChiTietTable.tangCaKetthuc: tangCaKetthuc,
    ChamCongChiTietTable.ghiChu: ghiChu,
    ChamCongChiTietTable.serverId: serverId,
    ChamCongChiTietTable.isSynced: isSynced,
    ChamCongChiTietTable.updatedAt: DateTime.now().toIso8601String(),
    ChamCongChiTietTable.isDeleted: isDeleted
  };
}

class UpsertChamCongNgayParam {
  final int? idChamCongNgay;
  final int? idBangChamCong;
  final int? idCongTrinh;
  final int idNhanVienCongTrinh;
  final String ngay; // 'yyyy-MM-dd'
  final int? trangThaiSang;
  final int? trangThaiChieu;
  final String? ghiChu;

  UpsertChamCongNgayParam({
    this.idChamCongNgay,
    this.idBangChamCong,
    this.idCongTrinh,
    required this.idNhanVienCongTrinh,
    required this.ngay,
    this.trangThaiSang,
    this.trangThaiChieu,
    this.ghiChu,
  });
}