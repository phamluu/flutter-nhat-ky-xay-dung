//Load kết quả từ hàm
class UngLuongDataColumns {
  static const idNhanVienCongTrinh = 'idNhanVienCongTrinh';
  static const idCongTrinh = 'idCongTrinh';
  static const nhanVienId = 'nhanVienId';
  static const hoTen = 'hoTen';
  static const idUngLuong = 'idUngLuong';
  static const soTien = 'soTien';
  static const ngayUng = 'ngayUng';
  static const lyDo = 'lyDo';
  static const isDeleted = 'is_deleted';
}
class UngLuongDataModel {
  final int idNhanVienCongTrinh;
  final int? idCongTrinh;

  final int? nhanVienId;
  final String? hoTen;

  final int? idUngLuong;
  final double? soTien;
  final DateTime? ngayUng;
  final String? lyDo;
  final bool? isDeleted;

  const UngLuongDataModel({
    required this.idNhanVienCongTrinh,
    this.idCongTrinh,
    this.nhanVienId,
    this.hoTen,
    this.idUngLuong,
    this.soTien,
    this.ngayUng,
    this.lyDo,
    this.isDeleted,
  });

  factory UngLuongDataModel.fromMap(Map<String, dynamic> map) {
    return UngLuongDataModel(
      idNhanVienCongTrinh: map[UngLuongDataColumns.idNhanVienCongTrinh] as int,
      idCongTrinh: map[UngLuongDataColumns.idCongTrinh] as int?,
      nhanVienId: map[UngLuongDataColumns.nhanVienId] as int?,
      hoTen: map[UngLuongDataColumns.hoTen] as String?,
      idUngLuong: map[UngLuongDataColumns.idUngLuong] as int?,
      soTien: (map[UngLuongDataColumns.soTien] as num?)?.toDouble(),
      ngayUng: map[UngLuongDataColumns.ngayUng] != null
          ? DateTime.tryParse(map[UngLuongDataColumns.ngayUng].toString())
          : null,
      lyDo: map[UngLuongDataColumns.lyDo] as String?,
      isDeleted: map[UngLuongDataColumns.isDeleted] == null
          ? null
          : map[UngLuongDataColumns.isDeleted] == 1,
    );
  }
}