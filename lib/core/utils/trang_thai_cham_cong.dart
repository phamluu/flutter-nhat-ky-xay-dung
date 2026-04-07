enum TrangThaiChamCong {
  vang(0, "Vắng"),
  coMat(1, "Có mặt"),
  khongXacDinh(-1, "KXĐ")
  ; // null hoặc -1

  final int value;
  final String label;

  const TrangThaiChamCong(this.value, this.label);

  // Chuyển từ int DB sang enum
  static TrangThaiChamCong fromValue(int? value) {
    switch (value) {
      case 0: return TrangThaiChamCong.vang;
      case 1: return TrangThaiChamCong.coMat;
      default: return TrangThaiChamCong.khongXacDinh;
    }
  }
}


// Extension để lấy label hiển thị
extension TrangThaiChamCongExtension on TrangThaiChamCong {
  String get label {
    switch (this) {
      case TrangThaiChamCong.vang:
        return "Vắng";
      case TrangThaiChamCong.coMat:
        return "Có mặt";
      case TrangThaiChamCong.khongXacDinh:
        return "-";
    }
  }

  // Chuyển từ số DB sang enum
  static TrangThaiChamCong fromValue(int? value) {
    switch (value) {
      case 0:
        return TrangThaiChamCong.vang;
      case 1:
        return TrangThaiChamCong.coMat;
      default:
        return TrangThaiChamCong.khongXacDinh;
    }
  }

  // Chuyển từ enum sang số DB
  int get value {
    switch (this) {
      case TrangThaiChamCong.vang:
        return 0;
      case TrangThaiChamCong.coMat:
        return 1;
      case TrangThaiChamCong.khongXacDinh:
        return -1;
    }
  }
}
