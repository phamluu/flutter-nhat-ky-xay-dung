import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_builder.dart';
import '../desktop/cong_trinh_list_desktop.dart';
import '../mobile/cong_trinh_list_mobile.dart';

class CongTrinhListPage extends StatelessWidget {
  const CongTrinhListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: const CongTrinhListMobile(),
      desktop: const CongTrinhListDesktop(),
    );
  }
}