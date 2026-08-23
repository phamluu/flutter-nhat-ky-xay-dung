import '../../../../data/tables/cham_cong_table.dart';

class BangChamCong {
  int? id;
  int? idCongTrinh;
  int? thang;
  int? nam;
  // String? thangValue;
  int? daKhoa ;
  String? ngayTao;
  String? serverId;
  int? isSynced;
  String? updatedAt;
  int? isDeleted;
  BangChamCong({
    this.id,
    this.idCongTrinh,
    this.thang,
    this.nam,
    // this.thangValue,
    this.daKhoa,
    this.ngayTao,
    this.serverId,
    this.isSynced,
    this.updatedAt,
    this.isDeleted
});
  // int? get thang {
  //   if (thangValue == null || !thangValue!.contains('-')) return null;
  //   return int.tryParse(thangValue!.split('-').last);
  // }
  // int? get nam {
  //   if (thangValue == null || !thangValue!.contains('-')) return null;
  //   return int.tryParse(thangValue!.split('-').first);
  // }
  String get thangValue {
    if (nam == null || thang == null) {
      return '';
    }
    return '$nam-${thang.toString().padLeft(2, '0')}';
  }
  factory BangChamCong.fromMap(Map<String, dynamic> map) => BangChamCong(
    id: map[ChamCongTable.id] as int,
    idCongTrinh: map[ChamCongTable.idCongTrinh] as int,
    // thangValue: map[ChamCongTable.thang] ?? '',
    thang: int.tryParse(map[ChamCongTable.thang]!.split('-').last),
    nam: int.tryParse(map[ChamCongTable.thang]!.split('-').first),
    daKhoa: map[ChamCongTable.daKhoa] as int?,
    ngayTao: map[ChamCongTable.ngayTao] as String,
    serverId: map[ChamCongTable.serverId] as String?,
    isSynced: map[ChamCongTable.isSynced] as int?,
    updatedAt: map[ChamCongTable.updatedAt] as String?,
    isDeleted: map[ChamCongTable.isDeleted] as int?,
  );
  /* insert vào db*/
  Map<String, dynamic> toMapInsert() => {
    ChamCongTable.idCongTrinh: idCongTrinh,
    ChamCongTable.thang: thangValue,
    ChamCongTable.daKhoa: daKhoa,
    ChamCongTable.ngayTao: DateTime.now().toIso8601String(),
    ChamCongTable.serverId: serverId,
    ChamCongTable.isSynced: isSynced,
    ChamCongTable.updatedAt: DateTime.now().toIso8601String(),
    ChamCongTable.isDeleted: isDeleted
  };
  /* update vào db*/
  Map<String, dynamic> toMapUpdate() => {
    ChamCongTable.idCongTrinh: idCongTrinh,
    ChamCongTable.thang: thangValue,
    ChamCongTable.daKhoa: daKhoa,
    ChamCongTable.serverId: serverId,
    ChamCongTable.isSynced: isSynced,
    ChamCongTable.updatedAt: DateTime.now().toIso8601String(),
    ChamCongTable.isDeleted: isDeleted
  };
}