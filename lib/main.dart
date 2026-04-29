import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/home/pages/HomeRouter.dart';
import 'package:sqflite/sqflite.dart';

import 'data/db_helper.dart';
import 'features/home/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Widget app = const MyApp();
  try{
    if (!kIsWeb) {
      await DBHelper.instance.database; // Chỉ chạy trên mobile
    }
  }catch (e, s) {
    debugPrint('Error opening database: $e');
    app = MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Lô khởi tạo DB: $e'),
        ),
      ),
    );
  }
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nhật ký xây dựng',
      theme: ThemeData(

        appBarTheme: AppBarTheme(
          backgroundColor:  Colors.orange,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
          titleMedium: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
          bodyMedium: TextStyle(color: Color(0xFF2C3E50)),
        ),
        // cardTheme: CardTheme(
        //   color: Colors.white,
        //   shadowColor: Colors.grey.withOpacity(0.2),
        //   elevation: 2,
        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        // ),
        useMaterial3: true,
      ),
      home: const HomeRouter()

      //const MyHomePage(title: 'Nhật ký xây dựng Home Page'),
    );
  }
}


Future<void> printDbPath() async {
  final dbPath = await getDatabasesPath();
  print("DB Path: $dbPath/database.db");
}