class KyLuongChiTietModel {
      int? id;
      int? idKyLuong;
      int? idLuongCoBan;
      int? idChamCongChiTiet;
      double? mucLuong;
      double? soCong;
      double? tienCong;

      String? serverId;
      int? isSynced;
      String? updatedAt;
      int? isDeleted;
      KyLuongChiTietModel({
        this.id,
        this.idKyLuong,
        this.idLuongCoBan,
        this.idChamCongChiTiet,
        this.mucLuong,
        this.soCong,
        this.tienCong,
        this.serverId,
        this.isSynced,
        this.updatedAt,
        this.isDeleted
      });
      Map<String, dynamic> toMap() {
        return {
          'id_ky_luong': idKyLuong,
          'id_luong_co_ban': idLuongCoBan,
          'id_cham_cong_chi_tiet': idChamCongChiTiet,
          'muc_luong': mucLuong,
          'so_cong': soCong,
          'tien_cong': tienCong,
        };
      }
}