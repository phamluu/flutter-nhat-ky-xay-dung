class DanhMucThuChi {
  final int? id;
  final String ten;

  DanhMucThuChi({this.id, required this.ten});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ten': ten,
    };
  }

  factory DanhMucThuChi.fromMap(Map<String, dynamic> map) {
    return DanhMucThuChi(
      id: map['id'],
      ten: map['ten'],
    );
  }
}
