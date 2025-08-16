class ThuChi {
  final int? id;
  final int idDanhMucThuChi;
  final int loai; // 0: chi, 1: thu
  final double soTien;
  final String? ghiChu;
  final String ngay;
  final int? idCongTrinh;
  final String ngayTao;

  ThuChi({
    this.id,
    required this.idDanhMucThuChi,
    required this.loai,
    required this.soTien,
    this.ghiChu,
    required this.ngay,
    this.idCongTrinh,
    required this.ngayTao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_danh_muc_thu_chi': idDanhMucThuChi,
      'loai': loai,
      'so_tien': soTien,
      'ghi_chu': ghiChu,
      'ngay': ngay,
      'id_cong_trinh': idCongTrinh,
      'ngay_tao': ngayTao,
    };
  }

  factory ThuChi.fromMap(Map<String, dynamic> map) {
    return ThuChi(
      id: map['id'],
      idDanhMucThuChi: map['id_danh_muc_thu_chi'],
      loai: map['loai'],
      soTien: map['so_tien'],
      ghiChu: map['ghi_chu'],
      ngay: map['ngay'],
      idCongTrinh: map['id_cong_trinh'],
      ngayTao: map['ngay_tao'],
    );
  }
}
