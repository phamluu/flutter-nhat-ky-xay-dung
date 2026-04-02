import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/cong_trinh/pages/ChiTietCongTrinhScreen.dart';
import 'package:nhat_ky_xay_dung/features/cong_trinh/pages/DanhSachCongTrinhScreen.dart';
import '../../../data/models/CongTrinh.dart';
import '../../../services/cong_trinh_service.dart';
import '_SectionHeader.dart';

class ProjectList extends StatefulWidget {
  const ProjectList({super.key});

  @override
  State<ProjectList> createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
  List<CongTrinh> projects = [];
  bool isLoading = true;
  final _service = CongTrinhService();

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => isLoading = true);
    try {
      final result = await _service.getDanhSachCongTrinh();
      setState(() => projects = result.take(3).toList()); // giữ nguyên kiểu List<CongTrinh>
    } catch (e) {
      print('Lỗi load dự án: $e');
      setState(() => projects = []);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(title: 'Công trình đang làm', onViewAll: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DanhSachCongTrinhScreen(),
            ),
          );
        }),
        const SizedBox(height: 8),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (projects.isEmpty)
          const Text('Không có dự án nào')
        else
          ...projects.map((p) => _ProjectItem(
            congTrinh: p,
            name: p.ten,
            image: p.hinhAnh,
            location: p.diaChi,
            progress: 1,
            ngayTao: p.ngayTao,
            updatedAt: p.ngayBatDau!.toString(),
            progressColor: Theme.of(context).colorScheme.secondary,
          )),
      ],
    );
  }
}

class _ProjectItem extends StatelessWidget {
  final CongTrinh congTrinh;
  final String name;
  final String? image;
  final String? location;
  final double progress;
  final String updatedAt;
  final Color progressColor;
  final String? ngayTao;
  const _ProjectItem({
    required this.congTrinh,
    required this.name,
    this.image,
    this.location,
    required this.progress,
    required this.updatedAt,
    required this.progressColor,
    this.ngayTao
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChiTietCongTrinhScreen(congTrinh: congTrinh),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              /// PHẦN THÔNG TIN (2/3)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      location ?? 'Chưa có địa chỉ',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: progress / 100,
                      color: Colors.orange,
                      backgroundColor: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 4),
                    Text("Tiến độ: $progress%"),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              /// PHẦN HÌNH (1/3)
              Expanded(
                flex: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 1,
                      child: image != null && File(image!).existsSync()
                          ? Image.file(
                        File(image!),
                        fit: BoxFit.cover,
                      )
                          : Image.asset(
                        'assets/noimage.png',
                        fit: BoxFit.cover,
                      ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
