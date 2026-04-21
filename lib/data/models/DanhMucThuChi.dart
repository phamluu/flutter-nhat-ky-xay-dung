class DanhMucThuChi {
  final int? id;
  final String ten;
  final int? isSynced;
  DanhMucThuChi({this.id, required this.ten, this.isSynced});

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
