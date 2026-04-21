import 'dart:io';

import 'package:flutter/material.dart';
import '../../../data/models/NhatKy.dart';
import '../../../services/nhat_ky_service.dart';
import '../widgets/weather_dropdown.dart';

class XemChiTietNhatKyScreen extends StatelessWidget {
  final NhatKy nhatKy;
  final _nhatKyService = NhatKyService();
  XemChiTietNhatKyScreen({super.key, required this.nhatKy});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nhatKy.tenNhatKy ?? "Chi tiết nhật ký"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ngày triển khai: ${nhatKy.ngayTrienKhai ?? "-"}",
              style: const TextStyle(fontSize: 14, color: Colors.pink),
            ),
            const SizedBox(height: 12),

            buildWeatherInfo("Thời tiết sáng", nhatKy.thoiTietSang),
            const SizedBox(height: 4),
            buildWeatherInfo("Thời tiết chiều", nhatKy.thoiTietChieu),

            const SizedBox(height: 12),
            const Divider(),

            // 🔥 PHẦN ẢNH
            const SizedBox(height: 12),
            const Text(
              "Hình ảnh",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildImageGrid(context),
            const SizedBox(height: 12),

            Text(
              nhatKy.noiDung ?? "-",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _nhatKyService.getImages(nhatKy.id!),
      builder: (context, snapshot) {
        // ⏳ Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // ❌ Lỗi hoặc không có data
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/noimage.png',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          );
        }

        // ✅ Có ảnh
        final paths = snapshot.data!;

        return GridView.builder(
          itemCount: paths.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _FullScreenImage(
                      images: paths,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(paths[index]),
                  fit: BoxFit.cover,
                )
              ),
            );
          },
        );
      },
    );
  }
}

class _FullScreenImage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenImage({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<_FullScreenImage> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: Image.file(File(widget.images[index]),fit: BoxFit.cover,),
            ),
          );
        },
      ),
    );
  }
}
