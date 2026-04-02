import 'package:flutter/material.dart';

class LuongNhanVienScreen extends StatefulWidget {
  const LuongNhanVienScreen({super.key});

  @override
  State<LuongNhanVienScreen> createState() => _LuongNhanVienScreenState();
}

class _LuongNhanVienScreenState extends State<LuongNhanVienScreen> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lương nhân viên"),
        backgroundColor: Colors.blue.shade100,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return Column(
            children: [
              Divider(
                color: Colors.grey.shade300,
                thickness: 1,
                height: 1,
              ),
            ],
          );
        },
      ),
    );
  }
}
