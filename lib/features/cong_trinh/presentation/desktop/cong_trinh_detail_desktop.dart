import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/presentation/desktop/bang_cham_cong_desktop.dart';
import 'package:nhat_ky_xay_dung/features/nhan_vien_cong_trinh/presentation/desktop/nhan_vien_cong_trinh_list_desktop.dart';
import 'package:nhat_ky_xay_dung/features/thu_chi/presentation/desktop/thu_chi_cong_trinh_desktop.dart';
import 'package:nhat_ky_xay_dung/features/ung_luong/presentation/desktop/ung_luong_list_desktop.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/thong_ke_controller.dart';
import '../../../nhat_ky_cong_trinh/presentation/desktop/nhat_ky_list_desktop.dart';
import '../../../tien_do/presentation/desktop/tien_do_desktop.dart';
import '../../data/models/CongTrinh.dart';


class CongTrinhDetailDesktop extends StatelessWidget {
  final CongTrinh congTrinh;

  const CongTrinhDetailDesktop({
    super.key,
    required this.congTrinh,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final controller = ThongKeController(
          idCongTrinh: congTrinh.id,
        );

        controller.loadCounts();

        return controller;
      },
      child: Consumer<ThongKeController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F6F8),
            appBar: AppBar(
              title: Text(congTrinh.ten),
              elevation: 0,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1400,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPageHeader(),

                      const SizedBox(height: 20),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: _buildProjectInformation(
                              context,
                            ),
                          ),

                          const SizedBox(width: 20),

                          Expanded(
                            flex: 6,
                            child: _buildModules(
                              context,
                              controller,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _buildDescription(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildPageHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                congTrinh.ten,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Thông tin tổng quan và quản lý công trình',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final progress = congTrinh.tienDo ?? 0;

    String text;
    IconData icon;

    if (progress >= 100) {
      text = 'Hoàn thành';
      icon = Icons.check_circle;
    } else if (progress > 0) {
      text = 'Đang thi công';
      icon = Icons.construction;
    } else {
      text = 'Chưa bắt đầu';
      icon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.orange,
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // THÔNG TIN CÔNG TRÌNH
  // ============================================================

  Widget _buildProjectInformation(BuildContext context) {
    return Column(
      children: [
        _buildImageCard(),

        const SizedBox(height: 16),

        _buildInfoCard(),

        const SizedBox(height: 16),

        _buildProgressCard(),
      ],
    );
  }

  Widget _buildImageCard() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: congTrinh.hinhAnh != null &&
          congTrinh.hinhAnh!.isNotEmpty &&
          File(congTrinh.hinhAnh!).existsSync()
          ? Image.file(
        File(congTrinh.hinhAnh!),
        fit: BoxFit.cover,
      )
          : Image.asset(
        'assets/noimage.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildInfoCard() {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin công trình',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),

          const SizedBox(height: 18),

          _infoRow(
            Icons.location_on_outlined,
            'Địa chỉ',
            congTrinh.diaChi ?? 'Chưa có địa chỉ',
          ),

          const SizedBox(height: 16),

          _infoRow(
            Icons.calendar_today_outlined,
            'Ngày bắt đầu',
            congTrinh.ngayBatDau ?? 'Chưa có',
          ),

          if (congTrinh.ngayKetThuc != null &&
              congTrinh.ngayKetThuc!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _infoRow(
              Icons.event_available_outlined,
              'Ngày kết thúc',
              congTrinh.ngayKetThuc!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 19,
            color: Colors.orange,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TIẾN ĐỘ
  // ============================================================

  Widget _buildProgressCard() {
    final progress = (congTrinh.tienDo ?? 0).clamp(0, 100);

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tiến độ công trình',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),

              Text(
                '${progress.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 10,
              color: Colors.orange,
              backgroundColor: Colors.grey.shade200,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            progress >= 100
                ? 'Công trình đã hoàn thành'
                : 'Tiến độ thực hiện hiện tại',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MODULES
  // ============================================================

  Widget _buildModules(
      BuildContext context,
      ThongKeController controller,
      ) {
    return _WhiteCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quản lý công trình',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Truy cập nhanh các chức năng của công trình',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              final crossAxisCount = width > 700 ? 4 : 3;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.9,
                children: [
                  _moduleCard(
                    context,
                    icon: Icons.people_outline,
                    title: 'Nhân viên',
                    value: controller
                        .soLuongNhanVienCongTrinh
                        .toString(),
                    color: const Color(0xFF27AE60),
                    page: NhanVienCongTrinhListDesktop(
                      idCongTrinh: congTrinh.id,
                      tenCongTrinh: congTrinh.ten,
                    ),
                  ),

                  _moduleCard(
                    context,
                    icon: Icons.timeline,
                    title: 'Tiến độ',
                    value: controller.soLuongKeHoach.toString(),
                    color: Colors.orange,
                    page: TienDoDesktop(
                      idCongTrinh: congTrinh.id!,
                      tenCongTrinh: congTrinh.ten,
                    ),
                  ),

                  _moduleCard(
                    context,
                    icon: Icons.menu_book_outlined,
                    title: 'Nhật ký',
                    value: controller.soLuongNhatKy.toString(),
                    color: Colors.blue,
                    page: NhatKyListDesktop(
                      idCongTrinh: congTrinh.id,
                      tenCongTrinh: congTrinh.ten,
                    ),
                  ),

                  _moduleCard(
                    context,
                    icon: Icons.access_time,
                    title: 'Bảng chấm công',
                    value: controller.soLuongCoMat.toString(),
                    color: Colors.indigo,
                    page: BangChamCongDesktop(
                      idCongTrinh: congTrinh.id,
                      tenCongTrinh: congTrinh.ten,
                    ),
                  ),

                  _moduleCard(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Thu chi',
                    value: controller.soLanThuChi.toString(),
                    color: Colors.teal,
                    page: ThuChiCongTrinhDesktop(
                      idCongTrinh: congTrinh.id,
                      tenCongTrinh: congTrinh.ten,
                    ),
                  ),

                  _moduleCard(
                    context,
                    icon: Icons.payments_outlined,
                    title: 'Ứng lương',
                    value: controller.soLuongUngLuong.toString(),
                    color: Colors.deepOrange,
                    page: UngLuongListDesktop(
                      idCongTrinh: congTrinh.id!,
                      tenCongTrinh: congTrinh.ten,
                    ),
                  ),

                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _moduleCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
        required Color color,
        required Widget page,
      }) {
    return _DesktopModuleCard(
      icon: icon,
      title: title,
      value: value,
      color: color,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => page,
          ),
        );
      },
    );
  }

  // ============================================================
  // MÔ TẢ
  // ============================================================

  Widget _buildDescription() {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mô tả công trình',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            congTrinh.moTa?.isNotEmpty == true
                ? congTrinh.moTa!
                : 'Chưa có mô tả cho công trình này.',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WHITE CARD
// ============================================================

class _WhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _WhiteCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ============================================================
// MODULE CARD
// ============================================================

class _DesktopModuleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _DesktopModuleCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  State<_DesktopModuleCard> createState() =>
      _DesktopModuleCardState();
}

class _DesktopModuleCardState
    extends State<_DesktopModuleCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,

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

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _hover
              ? widget.color.withOpacity(.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hover
                ? widget.color.withOpacity(.35)
                : Colors.grey.shade200,
          ),
        ),

        child: Material(
          color: Colors.transparent,

          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onTap,

            child: Padding(
              padding: const EdgeInsets.all(14),

              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,

                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(.1),
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        Text(
                          widget.title,
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          widget.value,
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: _hover
                        ? widget.color
                        : Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}