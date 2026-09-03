import '../../../../data/tables/phien_chot_cong_table.dart';

class PhienChotCong {
    int? id;
    int? idChamCong;
    String? maDot;
    String? tuNgay;
    String? denNgay;
    String? ngayChot;
    String? nguoiChot;
    String? ghiChu;
    String? serverId;
    int? isSynced;
    String? updatedAt;
    PhienChotCong({
      this.id,
      this.idChamCong,
      this.maDot,
      this.denNgay,
      this.ngayChot,
      this.nguoiChot,
      this.ghiChu,
      this.serverId,
      this.isSynced,
      this.updatedAt
  });
    Map<String, dynamic> toMapInsert() => {
      PhienChotCongTable.idChamCong: idChamCong,
      PhienChotCongTable.maDot: maDot,
      PhienChotCongTable.denNgay: denNgay,
      PhienChotCongTable.ngayChot: DateTime.now().toIso8601String(),
      PhienChotCongTable.nguoiChot: nguoiChot,
      PhienChotCongTable.ghiChu: ghiChu
    };
}