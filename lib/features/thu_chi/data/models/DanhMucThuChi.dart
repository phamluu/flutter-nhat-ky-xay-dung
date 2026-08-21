import '../../../../data/tables/danh_muc_thu_chi_table.dart';

class DanhMucThuChi {
  final int? id;
  final String ten;
  final int? isSynced;
  DanhMucThuChi({this.id, required this.ten, this.isSynced});

  Map<String, dynamic> toMap() {
    return {
      DanhMucThuChiTable.id: id,
      DanhMucThuChiTable.ten: ten,
    };
  }

  factory DanhMucThuChi.fromMap(Map<String, dynamic> map) {
    return DanhMucThuChi(
      id: map[DanhMucThuChiTable.id],
      ten: map[DanhMucThuChiTable.ten],
    );
  }
}
