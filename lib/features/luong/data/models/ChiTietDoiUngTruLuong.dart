import '../../../../data/tables/chi_tiet_doi_tru_ung_luong.dart';

class ChiTietDoiUngTruLuong{
  final int? id;
  final int? idBangLuong;
  final int? idUngLuong;
  final double? soTienDoiTru;
  final DateTime? ngayDoiTru;
  final String? serverId;
  final int? isSynced;
  final String? updatedAt;
  final int? isDeleted;
  final String? thangKey;
  int? get thang {
    if (thangKey == null || !thangKey!.contains('-')) return null;
    return int.tryParse(thangKey!.split('-').last);
  }
  int? get nam {
    if (thangKey == null || !thangKey!.contains('-')) return null;
    return int.tryParse(thangKey!.split('-').first);
  }
  ChiTietDoiUngTruLuong({
      this.id,
      this.idBangLuong,
      this.idUngLuong,
      this.soTienDoiTru,
      this.ngayDoiTru,
      this.serverId,
      this.isSynced,
      this.updatedAt,
      this.isDeleted,
      this.thangKey
  });
  factory ChiTietDoiUngTruLuong.fromMap(Map<String, dynamic> map) {
    return ChiTietDoiUngTruLuong(
      id: map[ChiTietDoiTruUngLuongTable.id],
      idBangLuong: map[ChiTietDoiTruUngLuongTable.idBangLuong],
      idUngLuong: map[ChiTietDoiTruUngLuongTable.idUngLuong],
      soTienDoiTru: (map[ChiTietDoiTruUngLuongTable.soTienDoiTru] as num).toDouble(),
      ngayDoiTru: DateTime.parse(map[ChiTietDoiTruUngLuongTable.ngayDoiTru]),
      serverId: map[ChiTietDoiTruUngLuongTable.serverId],
      isSynced: map[ChiTietDoiTruUngLuongTable.isSynced],
      updatedAt: map[ChiTietDoiTruUngLuongTable.updatedAt],
      isDeleted: map[ChiTietDoiTruUngLuongTable.isDeleted],
      thangKey: map['thangKey']?.toString(),
    );
  }
}