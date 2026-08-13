import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/router/app_router.dart';
import 'data/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (!kIsWeb) {
      if (Platform.isWindows ||
          Platform.isLinux ||
          Platform.isMacOS) {
        // SQLite cho Desktop
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      await DBHelper.instance.database;
    }

    runApp(const MyApp());
  } catch (e, s) {
    debugPrint('Error opening database: $e');
    debugPrintStack(stackTrace: s);

    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Text(
              'Lỗi khởi tạo DB:\n$e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nhật ký xây dựng',
      routerConfig: appRouter,
      theme: ThemeData(
        useMaterial3: true,

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2C3E50),
          elevation: 0,

          // Tạo đường border phía dưới AppBar
          shape: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),

          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),

        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
          titleMedium: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF2C3E50),
          ),
        ),
      ),
    );
  }
}