import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/home/presentation/desktop/home_desktop.dart';

import '../../../core/utils/AuthHelper.dart';
import '../../../viewmodel/UserModel.dart';
import '../../auth/presentation/desktop/login_desktop.dart';
import 'HomeUserPage.dart';
import 'home_page.dart';

class HomeRouter extends StatefulWidget {
  const HomeRouter({super.key});

  @override
  State<HomeRouter> createState() => _HomeRouterState();
}

class _HomeRouterState extends State<HomeRouter> {
  Future<AuthState>? _authFuture;

  @override
  void initState() {
    super.initState();
    _authFuture = AuthHelper.getAuthState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthState>(
      future: _authFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final auth = snapshot.data!;

        if (auth.isLoggedIn && !auth.isAdmin) {
          return const HomeUserPage();
        }
        return const HomeDesktop();
      },
    );
  }
}