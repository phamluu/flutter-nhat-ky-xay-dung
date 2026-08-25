import 'package:nhat_ky_xay_dung/core/utils/trang_thai_luong.dart';

import '../../../../core/utils/trang_thai_cham_cong.dart';

// Bảng chấm công tháng: lấy danh sách nhân viên theo công trình + tháng
class BangChamCongModel{
  int? id; // id bảng chấm công
  int? idCongTrinh;
  int? thang;
  int? nam;
  String? thangKey;
  List<ChamCongNhanVienModel>? chamCongNhanViens; // group theo từng nhân viên công trình
  BangChamCongModel({
    this.id,
    this.idCongTrinh,
    this.thang,
    this.nam,
    this.thangKey,
    this.chamCongNhanViens,
  });
}

//join nhân viên công trình + group theo từng nhân viên công trình
class ChamCongNhanVienModel {
  int? idNhanVienCongTrinh;
  final String? ten;
  final String? chucVu;
  final Map<String, ChamCongNgayLuong> data ;
  // Cột tổng công
  double get tongSoCong {
    return data.values.fold(
      0,
          (sum, item) => sum + item.chamCong.soCong,
    );
  }

  // Tính cột tổng lương
  double get tongTienCong {
    return data.values.fold(
      0,
          (sum, item) => sum + item.tienCongNgay,
    );
  }
  double? tongLuongChot; // Lấy trong bảng chốt lương
  int trangThaiChotLuong; // trạng thái chốt lương
  double get tongLuongHienThi {
    if (trangThaiChotLuong == TrangThaiLuong.dachot.value && tongLuongChot != null) {
      return tongLuongChot!;
    }
    return tongTienCong;
  }
  // end cột tổng lương

  // Cột Đã ứng
  final List<DaUng>? daUng;
  double tongUng;
  // double get tongUng {
  //   return daUng?.fold(
  //     0.0,
  //         (sum, item) => sum! + item.tienUng,
  //   ) ?? 0.0;
  // }
  double? tongUngChot;
  double get tongUngHienThi {
    if (trangThaiChotLuong == TrangThaiLuong.dachot.value && tongUngChot != null) {
      return tongUngChot!;
    }
    return tongUng;
  }
  // End cột đã ứng

  // Cột thực nhận
  double get thucNhan{
    return tongTienCong - tongUng;
  }
  double? thucNhanChot;
  double get thucNhanHienThi {
    if (trangThaiChotLuong == TrangThaiLuong.dachot.value && thucNhanChot != null) {
      return thucNhanChot!;
    }
    return thucNhan;
  }
  // End cột thực nhận

  int? idBangLuong; // Chốt lương => c idBangLuong
  double tongDaChi;
  ChamCongNhanVienModel({
    this.idNhanVienCongTrinh,
    this.ten,
    this.chucVu,
    required this.data,
    this.daUng,
    required this.tongUng,
    required this.trangThaiChotLuong,
    this.idBangLuong,
    this.tongLuongChot,
    this.thucNhanChot,
    this.tongUngChot,
    required this.tongDaChi
  });

}

// Chấm công chi tiết
class ChamCongNgay {
  int? id; // Dùng để update
  final TrangThaiChamCong sang;
  final TrangThaiChamCong chieu;
  final String? ghiChu;
  ChamCongNgay({
    this.id,
    required this.sang,
    required this.chieu,
    this.ghiChu
  });
  /// 👉 Tính công trong ngày
  double get soCong {
    double cong = 0;
    if (sang == TrangThaiChamCong.coMat) cong += 0.5;
    if (chieu == TrangThaiChamCong.coMat) cong += 0.5;
    return cong;
  }
  /// 👉 Hiển thị kí hiệu
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

// join theo lương ngày
class ChamCongNgayLuong {
  final ChamCongNgay chamCong;
  final double luongNgay; // Lương cơ bản được áp dụng trong ngày
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