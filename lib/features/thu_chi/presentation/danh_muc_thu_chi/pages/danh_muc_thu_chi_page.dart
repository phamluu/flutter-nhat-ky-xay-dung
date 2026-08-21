import 'package:flutter/material.dart';

import '../../../../../core/responsive/responsive_builder.dart';
import '../desktop/danh_muc_thu_chi_desktop.dart';
import '../mobile/danh_sach_danh_muc_thu_chi_mobile.dart';
class DanhMucThuChiPage extends StatelessWidget {
  const DanhMucThuChiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: const DanhSachDanhMucThuChiMobile(),
      desktop: const DanhMucThuChiDesktop(),
    );
  }
}