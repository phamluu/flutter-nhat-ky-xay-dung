import 'package:flutter/material.dart';

import '../../../core/utils/AuthHelper.dart';
import '../../../viewmodel/UserModel.dart';
import '../../auth/screens/LoginScreen.dart';
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
        return const HomePage();
      },
    );
  }
}