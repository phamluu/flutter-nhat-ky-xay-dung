import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/utils/trang_thai_dong_bo.dart';
import '../../../../core/utils/AuthHelper.dart';
import '../../../../core/utils/SyncColor.dart';
import '../../../cong_trinh/data/models/CongTrinh.dart';
import '../../../cong_trinh/data/respositories/CongTrinhReponsitory.dart';
import '../../../cong_trinh/presentation/cong_trinh/mobile/ChiTietCongTrinhScreen.dart';
import '../../../cong_trinh/presentation/cong_trinh/pages/cong_trinh_list_page.dart';
import '../../widgets/_SectionHeader.dart';

class ProjectList extends StatefulWidget {
  const ProjectList({super.key});

  @override
  State<ProjectList> createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
  List<CongTrinh> projects = [];
  bool isLoading = true;
  final _service = CongtrinhReponsitory();
  bool isLoggedIn = false;
  bool isAdmin = false;
  @override
  void initState() {
    super.initState();
    _loadProjects();
    checkLogin();
  }
  Future<void> checkLogin() async {
    final auth = await AuthHelper.getAuthState();
    setState(() {
      isLoggedIn = auth.isLoggedIn;
      isAdmin = auth.isAdmin;
    });
  }
  Future<void> _loadProjects() async {
    setState(() => isLoading = true);
    try {
      final result = await _service.getCongTrinhWithTienDo();
      setState(() => projects =
          result.take(3).toList());
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
        HomeSectionHeader(
            title: 'Công trình đang làm',
            onViewAll: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CongTrinhListPage(),
                ),
              ).then((_) {
                _loadProjects();
              });
            }),
        const SizedBox(height: 8),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (projects.isEmpty)
          const Text('Không có dự án nào')
        else
          ...projects.map((p) => _ProjectItem(
                isAdmin: isAdmin,
                isLoggedIn: isLoggedIn,
                congTrinh: p,
                name: p.ten,
                image: p.hinhAnh,
                location: p.diaChi,
                progress: p.tienDo ?? 0,
                ngayTao: p.ngayTao,
                updatedAt: p.ngayBatDau!.toString(),
                progressColor: Theme.of(context).colorScheme.secondary,
                onReload: _loadProjects,
              )),
      ],
    );
  }
}

class _ProjectItem extends StatelessWidget {
  final bool isAdmin;
  final bool isLoggedIn;
  final CongTrinh congTrinh;
  final String name;
  final String? image;
  final String? location;
  final double progress;
  final String updatedAt;
  final Color progressColor;
  final String? ngayTao;
  final VoidCallback onReload;
  const _ProjectItem(
      {
        required this.isAdmin,
        required this.isLoggedIn,
        required this.congTrinh,
      required this.name,
      this.image,
      this.location,
      required this.progress,
      required this.updatedAt,
      required this.progressColor,
      this.ngayTao,
      required this.onReload
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
          ).then((_) {
            onReload();
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SyncColor.background(congTrinh.isSynced),
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if(isAdmin || !isLoggedIn) ...[
                          Icon(
                            congTrinh.isSynced == TrangThaiDongBo.dadongbo.value
                                ? Icons.cloud_done
                                : Icons.cloud_off,
                            color: congTrinh.isSynced == TrangThaiDongBo.dadongbo.value
                                ? Colors.green
                                : Colors.orange,
                            size: 18,
                          ),
                        ]

                      ],
                    ),
                    Text(
                      location ?? 'Chưa có địa chỉ',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: progress/100,
                      color: Colors.orange,
                      backgroundColor: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 4),
                    Text("Tiến độ: ${(progress ?? 0).toStringAsFixed(1)}%"),
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
