import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'data/db_helper.dart';
import 'features/home/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try{
    if (!kIsWeb) {
      await DBHelper.instance.database; // Chỉ chạy trên mobile
    }
    runApp(const MyApp());
  }catch (e, s) {
    print('Error in main: $e');
    print(s);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nhật ký xây dựng',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E86C1),
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF2E86C1), // xanh công trình
          secondary: const Color(0xFFE67E22), // cam nổi bật
          surface: const Color(0xFFF4F6F7), // nền xám nhạt
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
      home: const HomePage()

      //const MyHomePage(title: 'Nhật ký xây dựng Home Page'),
    );
  }
}
