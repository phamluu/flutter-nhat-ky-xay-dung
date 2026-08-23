import 'package:go_router/go_router.dart';
import 'package:nhat_ky_xay_dung/features/nhan_vien/presentation/pages/nhan_vien_list_page.dart';
import 'package:nhat_ky_xay_dung/features/settings/presentation/pages/setting_page.dart';
import '../../features/cong_trinh/presentation/cong_trinh/pages/cong_trinh_list_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/luong/presentation/luong_co_ban/pages/luong_co_ban_page.dart';
import '../../features/thu_chi/presentation/danh_muc_thu_chi/pages/danh_muc_thu_chi_page.dart';
import '../shell/desktop_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return DesktopShell(
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            return const HomePage();
          },
        ),
        GoRoute(
          path: '/cong-trinh',
          builder: (context, state) {
            return const CongTrinhListPage();
          },
        ),
        GoRoute(
          path: '/danh-muc-thu-chi',
          builder: (context, state) {
            return const DanhMucThuChiPage();
          },
        ),
        GoRoute(
          path: '/nhan-vien',
          builder: (context, state) {
            return const NhanVienListPage();
          },
        ),
        GoRoute(
          path: '/luong-co-ban',
          builder: (context, state) {
            return const LuongCoBanPage();
          },
        ),
        GoRoute(
          path: '/setting',
          builder: (context, state) {
            return const SettingPage();
          },
        ),
      ],
    ),
  ],
);