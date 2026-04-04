import '../core/utils/trang_thai_cham_cong.dart';

class ChamCongModel {
  final String ten;
  final String chucVu;
  final Map<String, ChamCongNgay> data;
  final double? tongSoCong;
  final double? luongCoBan;
  final double daUng;
  final int trangThai;
  ChamCongModel({
    required this.ten,
    required this.chucVu,
    required this.data,
    this.tongSoCong,
    this.luongCoBan,
    required this.daUng,
    required this.trangThai,
  });
  double get tongLuong{
    if(luongCoBan == null || tongSoCong == null){
      return 0;
    }
    return luongCoBan! * tongSoCong!;
  }
  double get thucNhan{
    return tongLuong - daUng;
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