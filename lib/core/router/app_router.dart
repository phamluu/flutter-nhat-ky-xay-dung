import 'package:go_router/go_router.dart';
import '../../features/cong_trinh/presentation/pages/cong_trinh_list_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
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
      ],
    ),
  ],
);