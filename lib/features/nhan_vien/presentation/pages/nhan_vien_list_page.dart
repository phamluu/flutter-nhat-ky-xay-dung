import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/nhan_vien/presentation/desktop/nhan_vien_list_desktop.dart';

import '../../../../core/responsive/responsive_builder.dart';

class NhanVienListPage extends StatelessWidget {
  const NhanVienListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: const NhanVienListPage(),
      desktop: const NhanVienListDesktop(),
    );
  }
}