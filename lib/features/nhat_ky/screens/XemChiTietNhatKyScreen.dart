import 'package:flutter/material.dart';
import '../../../data/models/NhatKy.dart';
import '../widgets/weather_dropdown.dart';

class XemChiTietNhatKyScreen extends StatelessWidget {
  final NhatKy nhatKy;

  const XemChiTietNhatKyScreen({super.key, required this.nhatKy});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nhatKy.tenNhatKy ?? "Chi tiết nhật ký"),
        backgroundColor: Colors.blue.shade100,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text("Ngày triển khai: ${nhatKy.ngayTrienKhai ?? "-"}",
                style: const TextStyle(fontSize: 14, color: Colors.pink)),
            const SizedBox(height: 12),
            buildWeatherInfo("Thời tiết sáng", nhatKy.thoiTietSang),
            const SizedBox(height: 4),
            buildWeatherInfo("Thời tiết chiều", nhatKy.thoiTietChieu),
            const SizedBox(height: 4),
            Divider(),
            const SizedBox(height: 12),
            Text("${nhatKy.noiDung ?? "-"}",
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
