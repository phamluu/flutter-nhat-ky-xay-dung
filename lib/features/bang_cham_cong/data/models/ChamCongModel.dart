import 'package:nhat_ky_xay_dung/core/utils/trang_thai_luong.dart';

import '../../../../core/utils/trang_thai_cham_cong.dart';

class ChamCongLuongNhanVienModel{
      final ChamCongNhanVienModel chamCong;
      final LuongNhanVienModel luong;

      ChamCongLuongNhanVienModel({
        required this.chamCong,
        required this.luong
      });
      double get tongTienCong {
        return chamCong.tongTienCong;
      }
      double get tongLuongHienThi {
        if (luong.trangThaiChotLuong == TrangThaiLuong.dachot.value && luong.tongLuongChot != null) {
          return luong.tongLuongChot!;
        }
        return tongTienCong;
      }
      /// Tổng ứng hiển thị
      double get tongUngHienThi {
        if (luong.trangThaiChotLuong == TrangThaiLuong.dachot.value &&
            luong.tongUngChot != null) {
          return luong.tongUngChot!;
        }
        return luong.tongUng;
      }
      /// Thực nhận
      double get thucNhan {
        return tongTienCong - luong.tongUng;
      }
      /// Thực nhận hiển thị
      double get thucNhanHienThi {
        if (luong.trangThaiChotLuong == TrangThaiLuong.dachot.value &&
            luong.thucNhanChot != null) {
          return luong.thucNhanChot!;
        }
        return thucNhan;
      }

}
class LuongNhanVienModel {
  final double? tongLuongChot;
  final int? trangThaiChotLuong;
  final List<DaUng>? daUng;
  final double tongUng;
  final double truUng;
  final double? tongUngChot;
  final double? thucNhanChot;
  final int? idBangLuong;
  final double tongDaChi;

  double get ungPhatSinhSauChot {
    if (tongUngChot == null) return 0;
    return tongUng - tongUngChot!;
  }
  double get conPhaiTra {
    if (thucNhanChot == null) return 0;
    return thucNhanChot! - ungPhatSinhSauChot - thucNhanChot!;
  }
  LuongNhanVienModel({
    this.tongLuongChot,
    this.trangThaiChotLuong,
    this.daUng,
    required this.tongUng,
    required this.truUng,
    this.tongUngChot,
    this.thucNhanChot,
    this.idBangLuong,
    required this.tongDaChi,
  });
}


//join nhân viên công trình + group theo từng nhân viên công trình
class ChamCongNhanVienModel {
  final int? idNhanVienCongTrinh;
  final String? ten;
  final String? chucVu;
  /// Key = ngày, value = chấm công + lương ngày
  final Map<String, ChamCongNgayLuong> data;
  /// Tổng số công trong tháng
  double get tongSoCong {
    return data.values.fold(
      0,
          (sum, item) => sum + item.chamCong.soCong,
    );
  }
  /// Tổng tiền công trong tháng
  double get tongTienCong {
    return data.values.fold(
      0,
          (sum, item) => sum + item.tienCongNgay,
    );
  }
  ChamCongNhanVienModel({
    this.idNhanVienCongTrinh,
    this.ten,
    this.chucVu,
    required this.data,
  });
}

/**************DỮ LIỆU CỦA DATA *****************/
// Chấm công chi tiết
class ChamCongNgay {
  int? id; // Dùng để update
  int? idPhienChot;
  final TrangThaiChamCong sang;
  final TrangThaiChamCong chieu;
  final String? ghiChu;
  ChamCongNgay({
    this.id,
    required this.sang,
    required this.chieu,
    this.ghiChu,
    this.idPhienChot
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