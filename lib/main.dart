import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/router/app_router.dart';
import 'core/services/trial_service.dart';
import 'core/widgets/global_trial_banner.dart';
import 'data/db_helper.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (!kIsWeb) {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      await DBHelper.instance.database;
    }
    // Kiểm tra bản quyền ngầm ban đầu (không chặn app)
    if (!kIsWeb && (Platform.isWindows || Platform.isAndroid)) {
      await TrialService.instance.init();
      TrialService.instance.startPeriodicCheck();
    }
  } catch (e, s) {
    debugPrint('Lỗi khởi tạo DB/App: $e');
    debugPrintStack(stackTrace: s);
  }

  // Luôn luôn khởi chạy App chính
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nhật ký xây dựng',
      routerConfig: appRouter,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ],
      locale: const Locale('vi', 'VN'),
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2C3E50),
          elevation: 0,
          shape: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
      ),
      builder: (context, child) {
        return Scaffold(
          body: Column(
            children: [
              Expanded(child: child ?? const SizedBox.shrink()),
            ],
          ),
        );
      },
    );
  }
}

