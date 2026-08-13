import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/luong_co_ban/presentation/desktop/luong_co_ban_desktop.dart';
import 'package:nhat_ky_xay_dung/features/luong_co_ban/presentation/mobile/luong_coban_screen.dart';
import 'package:nhat_ky_xay_dung/features/nhan_vien/presentation/desktop/nhan_vien_list_desktop.dart';

import '../../../../core/responsive/responsive_builder.dart';

class LuongCoBanPage extends StatelessWidget {
  const LuongCoBanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: const LuongCoBanScreen(),
      desktop: const LuongCoBanDesktop(),
    );
  }
}