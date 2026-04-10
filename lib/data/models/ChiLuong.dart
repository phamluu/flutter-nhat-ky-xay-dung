class ChiLuongModel {
  final int? id;
  final int idBangLuong;
  final double soTien;
  final DateTime ngayChi;
  final String? ghiChu;
  final DateTime createdAt;

  ChiLuongModel({
    this.id,
    required this.idBangLuong,
    required this.soTien,
    required this.ngayChi,
    this.ghiChu,
    required this.createdAt,
  });

  factory ChiLuongModel.fromMap(Map<String, dynamic> map) {
    return ChiLuongModel(
      id: map['id'],
      idBangLuong: map['idBangLuong'],
      soTien: (map['soTien'] as num).toDouble(),
      ngayChi: DateTime.parse(map['ngayChi']),
      ghiChu: map['ghiChu'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idBangLuong': idBangLuong,
      'soTien': soTien,
      'ngayChi': ngayChi.toIso8601String(),
      'ghiChu': ghiChu,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}