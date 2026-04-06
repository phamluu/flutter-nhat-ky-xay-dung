import '../core/utils/trang_thai_cham_cong.dart';

// Bảng chấm công tháng
class ChamCongModel {
  int? idNhanVienCongTrinh;
  final String ten;
  final String chucVu;
  final Map<String, ChamCongNgayLuong> data;
  final List<DaUng>? daUng;
  final int trangThai;

  ChamCongModel({
    this.idNhanVienCongTrinh,
    required this.ten,
    required this.chucVu,
    required this.data,
    this.daUng,
    required this.trangThai,
  });
  // Tổng số công
  double get tongSoCong {
    return data.values.fold(
      0,
          (sum, item) => sum + item.chamCong.soCong,
    );
  }
  /// Tổng lương (tính từ data)
  /// Tổng công cả tháng
  double get tongTienCong {
    return data.values.fold(
      0,
          (sum, item) => sum + item.tienCongNgay,
    );
  }
  double get tongUng {
    return daUng?.fold(
      0.0,
          (sum, item) => sum! + item.tienUng,
    ) ?? 0.0;
  }
  double get thucNhan{
    return tongTienCong - tongUng;
  }
}

class ChamCongNgay {
  final TrangThaiChamCong sang;
  final TrangThaiChamCong chieu;

  ChamCongNgay({
    required this.sang,
    required this.chieu,
  });

  /// 👉 Tính công
  double get soCong {
    double cong = 0;
    if (sang == TrangThaiChamCong.coMat) cong += 0.5;
    if (chieu == TrangThaiChamCong.coMat) cong += 0.5;
    return cong;
  }

  /// 👉 Hiển thị
  String get hienThi {
    if (sang == TrangThaiChamCong.coMat &&
        chieu == TrangThaiChamCong.coMat) {
      return "X";
    }

    if (sang == TrangThaiChamCong.coMat ||
        chieu == TrangThaiChamCong.coMat) {
      return "/";
    }

    if (sang == TrangThaiChamCong.khongXacDinh &&
        chieu == TrangThaiChamCong.khongXacDinh) {
      return "...";
    }

    return "0";
  }
}

class ChamCongNgayLuong {
  final ChamCongNgay chamCong;
  final double luongNgay;

  ChamCongNgayLuong({
    required this.chamCong,
    required this.luongNgay,
  });

  double get tienCongNgay => chamCong.soCong * luongNgay;
}

// danh sách Ứng tiền trong tháng
class DaUng{
  final double tienUng;
  DaUng({
    required this.tienUng
  });
}