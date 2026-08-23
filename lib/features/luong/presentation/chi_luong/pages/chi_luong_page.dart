import 'package:flutter/material.dart';

import '../../../../../core/responsive/responsive_builder.dart';
import '../ChiLuongScreen.dart';
import '../desktop/chi_luong_desktop.dart';

class ChiLuongPage extends StatelessWidget {
  final int idBangLuong;
  final String? tenNhanVien;
  final String? tenCongTrinh;
  final double tongPhaiTra;

  const ChiLuongPage({
    super.key,
    required this.idBangLuong,
    this.tenNhanVien,
    this.tenCongTrinh,
    required this.tongPhaiTra,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: ChiLuongScreen(idBangLuong: idBangLuong, tenNhanVien: tenNhanVien, tongPhaiTra: tongPhaiTra),
      desktop: ChiLuongDesktop(idBangLuong: idBangLuong, tenNhanVien: tenNhanVien,
          tongPhaiTra: tongPhaiTra,
          tenCongTrinh: tenCongTrinh,
      ),
    );
  }
}