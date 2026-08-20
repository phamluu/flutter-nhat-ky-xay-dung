class TienDoCongTrinhModel {
  int? id;
  int idCongTrinh;
  String tenCongViec;
  String? moTa;
  String? ngayBatDau;
  String? ngayKetThuc;
  double? phanTramKeHoach;
  double? phanTramThucTe;
  int? trangThai;
  double? trongSo;
  String? ngayTao;
  final int? isSynced;

  TienDoCongTrinhModel({
    this.id,
    required this.idCongTrinh,
    required this.tenCongViec,
    this.moTa,
    this.ngayBatDau,
    this.ngayKetThuc,
    this.phanTramKeHoach,
    this.phanTramThucTe,
    this.trangThai,
    this.trongSo,
    this.ngayTao,
    this.isSynced
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic> {
      'id': id,
      'id_cong_trinh': idCongTrinh,
      'ten_cong_viec': tenCongViec,
      'mo_ta': moTa,
      'ngay_bat_dau': ngayBatDau,
      'ngay_ket_thuc': ngayKetThuc,
      'phan_tram_ke_hoach': phanTramKeHoach,
      'phan_tram_thuc_te': phanTramThucTe,
      'trang_thai': trangThai,
      'trong_so': trongSo,
    };
    if (ngayTao != null) {
      map['ngay_tao'] = ngayTao;
    }
    return map;
  }

  factory TienDoCongTrinhModel.fromMap(Map<String, dynamic> map) {
    return TienDoCongTrinhModel(
      id: map['id'],
      idCongTrinh: map['id_cong_trinh'],
      tenCongViec: map['ten_cong_viec'],
      moTa: map['mo_ta'],
      ngayBatDau: map['ngay_bat_dau'],
      ngayKetThuc: map['ngay_ket_thuc'],
      phanTramKeHoach: (map['phan_tram_ke_hoach'] as num?)?.toDouble(),
      phanTramThucTe: (map['phan_tram_thuc_te'] as num?)?.toDouble(),
      trangThai: map['trang_thai'],
      trongSo: (map['trong_so'] as num?)?.toDouble(),
      ngayTao: map['ngay_tao'],
    );
  }
}