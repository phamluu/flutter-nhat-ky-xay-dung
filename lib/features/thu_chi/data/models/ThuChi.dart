import 'package:nhat_ky_xay_dung/data/tables/cong_trinh_table.dart';

import '../../../../data/tables/thu_chi_table.dart';
import '../../../cong_trinh/data/models/CongTrinh.dart';
import 'DanhMucThuChi.dart';

class ThuChi {
  final int? id;
  final int? idDanhMucThuChi;
  final DanhMucThuChi? danhMucThuChi;
  final int loai; // 0: chi, 1: thu
  final double? donGia;
  final double? soLuong;
  final String? tenHangHoa;
  final String? donViTinh;
  final String? ghiChu;
  final String ngay;
  final int? idCongTrinh;
  final CongTrinh? congTrinh;
  final String ngayTao;
  final int? isSynced;
  double get thanhTien{
    return (donGia ?? 0) * (soLuong ?? 0);
}
  ThuChi({
    this.id,
    this.idDanhMucThuChi,
    this.danhMucThuChi,
    required this.loai,
    this.donGia,
    this.soLuong,
    this.tenHangHoa,
    this.donViTinh,
    this.ghiChu,
    required this.ngay,
    this.idCongTrinh,
    this.congTrinh,
    required this.ngayTao,
    this.isSynced
  });

  Map<String, dynamic> toMap() {
    final map = {
      ThuChiTable.id: id,
      ThuChiTable.id_danh_muc_thu_chi: idDanhMucThuChi,
      ThuChiTable.loai: loai,
      ThuChiTable.donGia: donGia,
      ThuChiTable.tenHangHoa: tenHangHoa,
      ThuChiTable.donViTinh: donViTinh,
      ThuChiTable.soLuong:soLuong,
      ThuChiTable.ngay: ngay,
      ThuChiTable.id_cong_trinh: idCongTrinh,
      ThuChiTable.ngay_tao: ngayTao,
    };
    return map;
  }

  factory ThuChi.fromMap(Map<String, dynamic> map,
      {CongTrinh? congTrinh, DanhMucThuChi? danhMucThuChi}) {
    return ThuChi(
      id: map[ThuChiTable.id],
      idDanhMucThuChi: map[ThuChiTable.id_danh_muc_thu_chi],
      danhMucThuChi: danhMucThuChi,
      loai: map[ThuChiTable.loai],
      donViTinh: map[ThuChiTable.donViTinh],
      tenHangHoa: map[ThuChiTable.tenHangHoa],
      soLuong: map[ThuChiTable.soLuong],
      donGia: map[ThuChiTable.donGia],
      ghiChu: map[ThuChiTable.ghi_chu],
      ngay: map[ThuChiTable.ngay],
      idCongTrinh: map[ThuChiTable.id_cong_trinh],
      congTrinh: congTrinh,
      ngayTao: map[ThuChiTable.ngay_tao],
    );
  }
}

class ThuChiViewModel {
  late ThuChiCongTyViewModel thuChiCongTy;
  late List<ThuChiCongTrinhViewModel> thuChiCongTrinhs;
  /// Tổng thu = cộng tất cả thu của danh mục + nhóm khác
  double get tongThu {
    final tongCongTrinh = thuChiCongTrinhs.fold<double>(
      0,
          (sum, dm) => sum + (dm.tongThu ?? 0),
    );
    return tongCongTrinh + (thuChiCongTy.tongThu ?? 0);
  }

  double get tongChi {
    final tongCongTrinh = thuChiCongTrinhs.fold<double>(
      0,
          (sum, dm) => sum + (dm.tongChi ?? 0),
    );
    return tongCongTrinh + (thuChiCongTy.tongChi ?? 0);
  }

  double get conLai => tongThu - tongChi;
}

class ThuChiCongTrinhViewModel {
  late CongTrinh congTrinh;
  late List<ThuChiDanhMucViewModel> thuChiDanhMucs;
  late ThuChiKhacViewModel thuChiKhacs;

  /// Tổng thu = tất cả khoản thu (loai == 1)
  double get tongThu {
    final dmThu = thuChiDanhMucs.fold<double>(
      0,
      (sum, dm) => sum + dm.tongThu!,
    );
    final khacThu = thuChiKhacs.tongThu;
    return dmThu + khacThu;
  }

  /// Tổng chi = tất cả khoản chi (loai == 0)
  double get tongChi {
    final dmChi = thuChiDanhMucs.fold<double>(
      0,
      (sum, dm) => sum + dm.tongChi,
    );
    final khacChi = thuChiKhacs.tongChi;
    return dmChi + khacChi + tamUngLuong + daChiLuong;
  }
  late double tamUngLuong;
  late double daChiLuong;
  /// Còn lại = Tổng thu - Tổng chi
  double get conLai => tongThu - tongChi ;
}

class ThuChiCongTyViewModel {
  late List<ThuChiDanhMucViewModel> thuChiDanhMucs;
  late ThuChiKhacViewModel thuChiKhacs;
  /// Tổng thu = cộng tất cả thu của danh mục + nhóm khác
  double get tongThu {
    final tongDanhMuc = thuChiDanhMucs.fold<double>(
      0,
          (sum, dm) => sum + (dm.tongThu ?? 0),
    );
    return tongDanhMuc + (thuChiKhacs.tongThu ?? 0);
  }

  /// Tổng chi = cộng tất cả chi của danh mục + nhóm khác
  double get tongChi {
    final tongDanhMuc = thuChiDanhMucs.fold<double>(
      0,
          (sum, dm) => sum + (dm.tongChi ?? 0),
    );
    return tongDanhMuc + (thuChiKhacs.tongChi ?? 0);
  }

  /// Số dư còn lại
  double get conLai => tongThu - tongChi;
}

// Thu chi có danh mục
class ThuChiDanhMucViewModel {
  late DanhMucThuChi? danhMucThuChi;
  late List<ThuChi>? thuchis;
  ThuChiDanhMucViewModel({
      this.danhMucThuChi,
     this.thuchis,
  });

  double get tongThu {
    if (thuchis == null || thuchis!.isEmpty) return 0;
    return thuchis!
        .where((tc) => tc.loai == 1)
        .fold(0.0, (sum, tc) => sum + tc.thanhTien);
  }

  double get tongChi {
    if (thuchis == null || thuchis!.isEmpty) return 0;
    return thuchis!
        .where((tc) => tc.loai == 0)
        .fold(0.0, (sum, tc) => sum + tc.thanhTien);
  }

  double get conLai => tongThu - tongChi;
}

// Thu chi khác
class ThuChiKhacViewModel {
  late List<ThuChi>? thuchis;
  ThuChiKhacViewModel({this.thuchis});

  double get tongThu =>
      (thuchis == null || thuchis!.isEmpty)
          ? 0
          : thuchis!
          .where((tc) => tc.loai == 1)
          .fold(0.0, (sum, tc) => sum + tc.thanhTien);

  double get tongChi =>
      (thuchis == null || thuchis!.isEmpty)
          ? 0
          : thuchis!
          .where((tc) => tc.loai == 0)
          .fold(0.0, (sum, tc) => sum + tc.thanhTien);

  double get conLai => tongThu - tongChi;
}
