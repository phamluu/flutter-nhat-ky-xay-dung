import 'package:nhat_ky_xay_dung/data/tables/bang_luong_table.dart';

class BangLuong {
      int? id;
      int idNhanVienCongTrinh;
      int idBangChamCong;
      double tongCong;
      double tongLuong;
      double tongUng;
      double thucNhan;
      int? trangThai;
      String? ngayChot;
      String? server_id;
      int? is_synced;
      String? updated_at;
      int? is_deleted;
      BangLuong({
        this.id,
        required this.idNhanVienCongTrinh,
        required this.idBangChamCong,
        required this.tongCong,
        required this.tongLuong,
        required this.tongUng,
        required this.thucNhan,
        this.trangThai,
        this.ngayChot,
        this.server_id,
        this.is_synced,
        this.updated_at,
        this.is_deleted
    });
      factory BangLuong.fromMap(Map<String, dynamic> map) => BangLuong(
        id: map[BangLuongTable.id] as int,
        idNhanVienCongTrinh: map[BangLuongTable.idNhanVienCongTrinh] as int,
        idBangChamCong: map[BangLuongTable.idBangChamCong] as int,
        tongCong: map[BangLuongTable.tongCong] as double,
        tongLuong: map[BangLuongTable.tongLuong] as double,
        tongUng: map[BangLuongTable.tongUng] as double,
        thucNhan: map[BangLuongTable.thucNhan] as double,
        trangThai: map[BangLuongTable.trangThai] as int?,
        ngayChot: map[BangLuongTable.ngayChot] as String?,
        server_id: map[BangLuongTable.server_id] as String?,
        is_synced: map[BangLuongTable.is_synced] as int?,
        updated_at: map[BangLuongTable.updated_at] as String?,
        is_deleted: map[BangLuongTable.is_deleted] as int?,
      );
      Map<String, dynamic> toMapInsert() => {
        BangLuongTable.idNhanVienCongTrinh: idNhanVienCongTrinh,
        BangLuongTable.idBangChamCong: idBangChamCong,
        BangLuongTable.tongCong: tongCong,
        BangLuongTable.tongLuong: tongLuong,
        BangLuongTable.tongUng: tongUng,
        BangLuongTable.thucNhan: thucNhan,
        BangLuongTable.trangThai: trangThai,
        BangLuongTable.ngayChot: ngayChot,
        BangLuongTable.server_id: server_id,
        BangLuongTable.is_synced: is_synced,
        BangLuongTable.updated_at: DateTime.now().toIso8601String(),
        BangLuongTable.is_deleted: is_deleted,
      };
      Map<String, dynamic> toMapUpdate() => {
        BangLuongTable.idNhanVienCongTrinh: idNhanVienCongTrinh,
        BangLuongTable.idBangChamCong: idBangChamCong,
        BangLuongTable.tongCong: tongCong,
        BangLuongTable.tongLuong: tongLuong,
        BangLuongTable.tongUng: tongUng,
        BangLuongTable.thucNhan: thucNhan,
        BangLuongTable.trangThai: trangThai,
        BangLuongTable.ngayChot: ngayChot,
        BangLuongTable.server_id: server_id,
        BangLuongTable.is_synced: is_synced,
        BangLuongTable.updated_at: DateTime.now().toIso8601String(),
        BangLuongTable.is_deleted: is_deleted,
      };
}