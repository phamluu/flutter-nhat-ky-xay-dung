import 'package:nhat_ky_xay_dung/data/tables/ky_luong_table.dart';

class BangLuong {
      int? id;
      int idNhanVienCongTrinh;
      int? idPhienChot;
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
        this.idPhienChot,
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
        id: map[KyLuongTable.id] as int,
        idNhanVienCongTrinh: map[KyLuongTable.idNhanVienCongTrinh] as int,
        idPhienChot: map[KyLuongTable.idPhienChot] as int,
        tongCong: map[KyLuongTable.tongCong] as double,
        tongLuong: map[KyLuongTable.tongLuong] as double,
        tongUng: map[KyLuongTable.tongUng] as double,
        thucNhan: map[KyLuongTable.thucNhan] as double,
        trangThai: map[KyLuongTable.trangThai] as int?,
        ngayChot: map[KyLuongTable.ngayChot] as String?,
        server_id: map[KyLuongTable.server_id] as String?,
        is_synced: map[KyLuongTable.is_synced] as int?,
        updated_at: map[KyLuongTable.updated_at] as String?,
        is_deleted: map[KyLuongTable.is_deleted] as int?,
      );
      Map<String, dynamic> toMapInsert() => {
        KyLuongTable.idNhanVienCongTrinh: idNhanVienCongTrinh,
        KyLuongTable.idPhienChot: idPhienChot,
        KyLuongTable.tongCong: tongCong,
        KyLuongTable.tongLuong: tongLuong,
        KyLuongTable.tongUng: tongUng,
        KyLuongTable.thucNhan: thucNhan,
        KyLuongTable.trangThai: trangThai,
        KyLuongTable.ngayChot: ngayChot,
        KyLuongTable.server_id: server_id,
        KyLuongTable.is_synced: is_synced,
        KyLuongTable.updated_at: DateTime.now().toIso8601String(),
        KyLuongTable.is_deleted: is_deleted,
      };
      Map<String, dynamic> toMapUpdate() => {
        KyLuongTable.idNhanVienCongTrinh: idNhanVienCongTrinh,
        KyLuongTable.idPhienChot: idPhienChot,
        KyLuongTable.tongCong: tongCong,
        KyLuongTable.tongLuong: tongLuong,
        KyLuongTable.tongUng: tongUng,
        KyLuongTable.thucNhan: thucNhan,
        KyLuongTable.trangThai: trangThai,
        KyLuongTable.ngayChot: ngayChot,
        KyLuongTable.server_id: server_id,
        KyLuongTable.is_synced: is_synced,
        KyLuongTable.updated_at: DateTime.now().toIso8601String(),
        KyLuongTable.is_deleted: is_deleted,
      };
}