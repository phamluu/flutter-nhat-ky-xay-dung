import '../../../../data/tables/chi_tiet_doi_tru_ung_luong.dart';

class Chitietdoiungtruluong {
  final int? id;
  final int? idBangLuong;
  final int? idUngLuong;
  final double? soTienDoiTru;
  final DateTime? ngayDoiTru;
  final String? serverId;
  final int? isSynced;
  final String? updatedAt;
  final int? isDeleted;
  Chitietdoiungtruluong({
      this.id,
      this.idBangLuong,
      this.idUngLuong,
      this.soTienDoiTru,
      this.ngayDoiTru,
      this.serverId,
      this.isSynced,
      this.updatedAt,
      this.isDeleted
  });
  factory Chitietdoiungtruluong.fromMap(Map<String, dynamic> map) {
    return Chitietdoiungtruluong(
      id: map[ChiTietDoiTruUngLuongTable.tableName],
      idBangLuong: map[ChiTietDoiTruUngLuongTable.idBangLuong],
      idUngLuong: map[ChiTietDoiTruUngLuongTable.idUngLuong],
      soTienDoiTru: (map[ChiTietDoiTruUngLuongTable.soTienDoiTru] as num).toDouble(),
      ngayDoiTru: DateTime.parse(map[ChiTietDoiTruUngLuongTable.ngayDoiTru]),
      serverId: map[ChiTietDoiTruUngLuongTable.serverId],
      isSynced: map[ChiTietDoiTruUngLuongTable.isSynced],
      updatedAt: map[ChiTietDoiTruUngLuongTable.updatedAt],
      isDeleted: map[ChiTietDoiTruUngLuongTable.isDeleted],
    );
  }
}