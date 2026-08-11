import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/home/presentation/desktop/home_desktop.dart';
import 'package:nhat_ky_xay_dung/features/home/presentation/mobile/home_mobile.dart';

import '../../../../core/responsive/responsive_builder.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: const HomeMobile(),
      desktop: const HomeDesktop(),
    );
  }
}