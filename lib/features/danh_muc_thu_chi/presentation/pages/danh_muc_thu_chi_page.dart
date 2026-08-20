import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/danh_muc_thu_chi/presentation/desktop/danh_muc_thu_chi_desktop.dart';
import 'package:nhat_ky_xay_dung/features/danh_muc_thu_chi/presentation/mobile/danh_sach_danh_muc_thu_chi_mobile.dart';

import '../../../../core/responsive/responsive_builder.dart';

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