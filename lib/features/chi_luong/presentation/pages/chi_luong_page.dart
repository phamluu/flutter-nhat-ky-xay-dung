import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/chi_luong/ChiLuongScreen.dart';
import 'package:nhat_ky_xay_dung/features/chi_luong/presentation/desktop/chi_luong_desktop.dart';

import '../../../../core/responsive/responsive_builder.dart';

class ChiLuongPage extends StatelessWidget {
  final int idBangLuong;
  final String? tenNhanVien;
  final String? tenCongTrinh;
  final double tongPhaiTra;
  final int thang;
  final int nam;

  const ChiLuongPage({
    super.key,
    required this.idBangLuong,
    this.tenNhanVien,
    this.tenCongTrinh,
    required this.tongPhaiTra,
    required this.thang,
    required this.nam
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: ChiLuongScreen(idBangLuong: idBangLuong, tenNhanVien: tenNhanVien, tongPhaiTra: tongPhaiTra),
      desktop: ChiLuongDesktop(idBangLuong: idBangLuong, tenNhanVien: tenNhanVien,
          tongPhaiTra: tongPhaiTra,
          tenCongTrinh: tenCongTrinh,
          thang:thang,
          nam:nam,
      ),
    );
  }
}