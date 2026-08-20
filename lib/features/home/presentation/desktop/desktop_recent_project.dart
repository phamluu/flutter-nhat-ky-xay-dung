import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nhat_ky_xay_dung/features/cong_trinh/presentation/desktop/cong_trinh_detail_desktop.dart';

import '../../../cong_trinh/data/models/CongTrinh.dart';
import '../../../cong_trinh/data/respositories/CongTrinhReponsitory.dart';

class DesktopRecentProjects extends StatefulWidget {
  const DesktopRecentProjects({
    super.key,
  });

  @override
  State<DesktopRecentProjects> createState() =>
      _DesktopRecentProjectsState();
}

class _DesktopRecentProjectsState
    extends State<DesktopRecentProjects> {
  final _service = CongtrinhReponsitory();

  List<CongTrinh> projects = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  /// Load danh sách công trình gần đây
  Future<void> _loadProjects() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final result =
      await _service.getCongTrinhWithTienDo();

      if (!mounted) return;

      setState(() {
        // Chỉ lấy 5 công trình gần đây
        projects = result.take(5).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Lỗi load công trình gần đây: $e',
      );

      if (!mounted) return;

      setState(() {
        projects = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),

          const Divider(height: 1),

          // ============================
          // LOADING
          // ============================

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )

          // ============================
          // KHÔNG CÓ DỮ LIỆU
          // ============================

          else if (projects.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.apartment_outlined,
                      size: 40,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Chưa có công trình nào',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )

          // ============================
          // DANH SÁCH
          // ============================

          else
            ...projects.map(
                  (project) => _ProjectRow(
                project: project,
                onReload: _loadProjects,
              ),
            ),
        ],
      ),
    );
  }

  /// Header "Công trình gần đây"
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        12,
        18,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Công trình gần đây',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Theo dõi tiến độ các công trình',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: () async {
              await context.push('/cong-trinh');
              // Khi quay lại Home
              // thì load lại dữ liệu
              await _loadProjects();
            },
            child: const Text(
              'Xem tất cả',
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// PROJECT ROW
// ============================================================

class _ProjectRow extends StatefulWidget {
  final CongTrinh project;

  final VoidCallback onReload;

  const _ProjectRow({
    required this.project,
    required this.onReload,
  });

  @override
  State<_ProjectRow> createState() =>
      _ProjectRowState();
}

class _ProjectRowState
    extends State<_ProjectRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;

    // ========================================================
    // TIẾN ĐỘ
    // ========================================================

    final double progress =
    (project.tienDo ?? 0)
        .toDouble()
        .clamp(0.0, 100.0);

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hover = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hover = false;
        });
      },
      child: InkWell(
        onTap: () async {
          // ==================================================
          // MỞ CHI TIẾT CÔNG TRÌNH
          // ==================================================

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CongTrinhDetailDesktop(
                congTrinh: project,
              ),
            ),
          );
          // ==================================================
          // QUAY LẠI -> LOAD LẠI DỮ LIỆU
          // ==================================================

          widget.onReload();
        },
        child: AnimatedContainer(
          duration:
          const Duration(milliseconds: 150),

          padding:
          const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),

          color: _hover
              ? Colors.grey.shade50
              : Colors.white,

          child: Row(
            children: [
              // =================================================
              // ẢNH
              // =================================================

              _buildImage(project),

              const SizedBox(width: 14),

              // =================================================
              // THÔNG TIN CÔNG TRÌNH
              // =================================================

              Expanded(
                flex: 4,
                child:
                _buildProjectInfo(project),
              ),

              const SizedBox(width: 30),

              // =================================================
              // TIẾN ĐỘ
              // =================================================

              Expanded(
                flex: 3,
                child:
                _buildProgress(progress),
              ),

              const SizedBox(width: 30),

              // =================================================
              // TRẠNG THÁI
              // =================================================

              SizedBox(
                width: 120,
                child:
                _buildStatus(progress),
              ),

              const SizedBox(width: 12),

              // =================================================
              // MŨI TÊN
              // =================================================

              Icon(
                Icons.chevron_right,
                color: _hover
                    ? Colors.orange
                    : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // IMAGE
  // ==========================================================

  Widget _buildImage(
      CongTrinh project,
      ) {
    final imagePath = project.hinhAnh;

    final bool hasImage =
        imagePath != null &&
            imagePath.isNotEmpty &&
            File(imagePath).existsSync();

    return ClipRRect(
      borderRadius:
      BorderRadius.circular(8),
      child: SizedBox(
        width: 65,
        height: 55,
        child: hasImage
            ? Image.file(
          File(imagePath!),
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) {
            return Image.asset(
              'assets/noimage.png',
              fit: BoxFit.cover,
            );
          },
        )
            : Image.asset(
          'assets/noimage.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // ==========================================================
  // PROJECT INFO
  // ==========================================================

  Widget _buildProjectInfo(
      CongTrinh project,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          project.ten,
          maxLines: 1,
          overflow:
          TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight:
            FontWeight.w600,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 5),

        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 14,
              color:
              Colors.grey.shade500,
            ),

            const SizedBox(width: 4),

            Expanded(
              child: Text(
                project.diaChi ??
                    'Chưa có địa chỉ',
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color:
                  Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // PROGRESS
  // ==========================================================

  Widget _buildProgress(
      double progress,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Tiến độ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const Spacer(),

            Text(
              '${progress.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 7),

        ClipRRect(
          borderRadius:
          BorderRadius.circular(5),
          child:
          LinearProgressIndicator(
            value: progress / 100,
            minHeight: 7,
            backgroundColor:
            Colors.grey.shade200,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // STATUS
  // ==========================================================

  Widget _buildStatus(
      double progress,
      ) {
    String text;
    IconData icon;

    if (progress >= 100) {
      text = 'Hoàn thành';
      icon =
          Icons.check_circle_outline;
    } else if (progress > 0) {
      text = 'Đang thi công';
      icon = Icons.construction;
    } else {
      text = 'Chưa bắt đầu';
      icon = Icons.schedule;
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color:
        Colors.orange.withOpacity(
          .08,
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: Colors.orange,
          ),

          const SizedBox(width: 5),

          Flexible(
            child: Text(
              text,
              overflow:
              TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}