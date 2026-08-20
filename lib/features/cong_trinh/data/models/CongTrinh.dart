import '../../../../data/tables/cong_trinh_table.dart';

class CongTrinh {
  final int? id;           // Khóa chính
  final String ten;        // Tên công trình
  final String? diaChi;    // Địa chỉ
  final String? moTa;      // Mô tả chi tiết
  final String? ngayBatDau; // yyyy-MM-dd
  final String? ngayKetThuc; // yyyy-MM-dd (có thể null)
  final String? hinhAnh;
  final double? tienDo;
  final String? ngayTao;
  final int? isSynced;
  final String? server_id;
  CongTrinh({
    this.id,
    required this.ten,
    this.diaChi,
    this.moTa,
    this.ngayBatDau,
    this.ngayKetThuc,
    this.hinhAnh,
    this.tienDo,
    this.ngayTao,
    this.isSynced,
    this.server_id
  });

  /// Convert object -> Map (dùng để insert/update vào SQLite)
  Map<String, dynamic> toMapInsert() {
    return {
      CongTrinhTable.ten: ten,
      CongTrinhTable.diaChi: diaChi,
      CongTrinhTable.moTa: moTa,
      CongTrinhTable.ngayBatDau: ngayBatDau,
      CongTrinhTable.ngayKetThuc: ngayKetThuc,
      CongTrinhTable.hinhAnh: hinhAnh,
      CongTrinhTable.serverId: server_id,
      CongTrinhTable.ngayTao: DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> toMapUpdate() {
    return {
      CongTrinhTable.ten: ten,
      CongTrinhTable.diaChi: diaChi,
      CongTrinhTable.moTa: moTa,
      CongTrinhTable.ngayBatDau: ngayBatDau,
      CongTrinhTable.ngayKetThuc: ngayKetThuc,
      CongTrinhTable.hinhAnh: hinhAnh,
      CongTrinhTable.serverId: server_id
    };
  }
  /// Convert Map -> object (dùng khi đọc từ SQLite)
  factory CongTrinh.fromMap(Map<String, dynamic> map) {
    return CongTrinh(
        id: map[CongTrinhTable.id],
        ten: map[CongTrinhTable.ten],
        diaChi: map[CongTrinhTable.diaChi],
        moTa: map[CongTrinhTable.moTa],
        ngayBatDau: map[CongTrinhTable.ngayBatDau],
        ngayKetThuc: map[CongTrinhTable.ngayKetThuc],
        hinhAnh: map[CongTrinhTable.hinhAnh],
        ngayTao: map[CongTrinhTable.ngayTao],
        isSynced: map[CongTrinhTable.isSynced],
        server_id: map[CongTrinhTable.serverId]
    );
  }
  // 👉 Thêm copyWith ở đây
  CongTrinh copyWith({
    int? id,
    String? ten,
    String? diaChi,
    String? moTa,
    String? ngayBatDau,
    String? ngayKetThuc,
    String? hinhAnh,
    String? ngayTao,
  }) {
    return CongTrinh(
      id: id ?? this.id,
      ten: ten ?? this.ten,
      diaChi: diaChi ?? this.diaChi,
      moTa: moTa ?? this.moTa,
      ngayBatDau: ngayBatDau ?? this.ngayBatDau,
      ngayKetThuc: ngayKetThuc ?? this.ngayKetThuc,
      hinhAnh: hinhAnh?? this.hinhAnh,
      ngayTao: ngayTao ?? this.ngayTao
    );
  }
}
