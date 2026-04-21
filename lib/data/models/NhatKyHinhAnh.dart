class NhatKyHinhAnh {
  final int? id;
  final int idNhatKy;
  final String url;
  final int? isSynced;
  NhatKyHinhAnh({
    this.id,
    required this.idNhatKy,
    required this.url,
    this.isSynced
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_nhat_ky': idNhatKy,
      'duong_dan': url,
    };
  }

  factory NhatKyHinhAnh.fromMap(Map<String, dynamic> map) {
    return NhatKyHinhAnh(
      id: map['id'],
      idNhatKy: map['id_nhat_ky'],
      url: map['url'],
    );
  }
}