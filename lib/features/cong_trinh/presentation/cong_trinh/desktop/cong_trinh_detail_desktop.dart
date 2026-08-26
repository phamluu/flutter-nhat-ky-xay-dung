import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/presentation/desktop/bang_cham_cong_list_desktop.dart';
import 'package:provider/provider.dart';
import '../../../../../controllers/thong_ke_controller.dart';
import '../../../../../services/thong_ke_service.dart';
import '../../../../bang_cham_cong/presentation/desktop/bang_cham_cong_desktop.dart';
import '../../../../luong/presentation/ung_luong/desktop/ung_luong_list_desktop.dart';
import '../../../../thu_chi/presentation/thu_chi/desktop/thu_chi_cong_trinh_desktop.dart';
import '../../../data/models/CongTrinh.dart';
import '../../nhan_vien_cong_trinh/desktop/nhan_vien_cong_trinh_list_desktop.dart';
import '../../nhat_ky_cong_trinh/desktop/nhat_ky_list_desktop.dart';
import '../../tien_do_cong_trinh/desktop/tien_do_desktop.dart';
import 'moduleCard.dart';

class CongTrinhDetailDesktop extends StatefulWidget {
  final CongTrinh congTrinh;
  const CongTrinhDetailDesktop({
    super.key,
    required this.congTrinh,
  });

  @override
  State<CongTrinhDetailDesktop> createState() =>
      _CongTrinhDetailDesktopState();
}

class _CongTrinhDetailDesktopState extends State<CongTrinhDetailDesktop> {
  int countNhanVien = 0;
  int countTienDo = 0;
  int countNhatKy= 0;
  int countBangChamCong= 0;
  int countThuChi= 0;
  int countUngLuong= 0;
  late final ThongKeService _service;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = ThongKeService();
    final idCongTrinh = widget.congTrinh.id;
    final _countNhanVien =await service.getSoLuongNhanVienCongTrinh(idCongTrinh);
    final _countNhatKy =await service.getSoLuongNhatKy(idCongTrinh);
    final _countThuChi =await service.getSoLanThuChi(idCongTrinh);
    final _countUngLuong =await service.getSoLuongUngLuong(idCongTrinh);
    final _countBangChamCong = await service.getSoLuongBangChamCong(idCongTrinh);
    final _countTienDo =await service.getSoLuongKeHoach(idCongTrinh);
    if (!mounted) return;
    setState(() {
      this.countNhanVien = _countNhanVien;
      this.countNhatKy = _countNhatKy;
      this.countThuChi = _countThuChi;
      this.countUngLuong = _countUngLuong;
      this.countBangChamCong = _countBangChamCong;
      this.countTienDo = _countTienDo;
    });
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
      },
      child: Consumer(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F6F8),
            appBar: AppBar(
              title: Text(widget.congTrinh.ten),
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
                            child: Column(
                              children: [
                                _buildModules(context,),
                                const SizedBox(height: 20),
                                _buildProgressCard()
                              ],
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

  Widget _buildModules(
      BuildContext context
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
                  moduleCard(
                    context,
                    icon: Icons.people_outline,
                    title: 'Nhân viên',
                    value: countNhanVien.toString(),
                    color: const Color(0xFF27AE60),
                    page: NhanVienCongTrinhListDesktop(
                      idCongTrinh: widget.congTrinh.id,
                      tenCongTrinh: widget.congTrinh.ten,
                    ),
                  ),

                  moduleCard(
                    context,
                    icon: Icons.timeline,
                    title: 'Kế hoạch',
                    value: countTienDo.toString(),
                    color: Colors.orange,
                    page: TienDoDesktop(
                      idCongTrinh: widget.congTrinh.id!,
                      tenCongTrinh: widget.congTrinh.ten,
                    ),
                  ),

                  moduleCard(
                    context,
                    icon: Icons.menu_book_outlined,
                    title: 'Nhật ký',
                    value: countNhatKy.toString(),
                    color: Colors.blue,
                    page: NhatKyListDesktop(
                      idCongTrinh: widget.congTrinh.id,
                      tenCongTrinh: widget.congTrinh.ten,
                    ),
                  ),

                  moduleCard(
                    context,
                    icon: Icons.access_time,
                    title: 'Bảng chấm công',
                    value: countBangChamCong.toString(),
                    color: Colors.indigo,
                    page: BangChamCongListDesktop(
                      idCongTrinh: widget.congTrinh.id,
                      tenCongTrinh: widget.congTrinh.ten,
                    ),
                  ),

                  moduleCard(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Thu chi',
                    value: countThuChi.toString(),
                    color: Colors.teal,
                    page: ThuChiCongTrinhDesktop(
                      idCongTrinh: widget.congTrinh.id,
                      tenCongTrinh: widget.congTrinh.ten,
                    ),
                  ),

                  moduleCard(
                    context,
                    icon: Icons.payments_outlined,
                    title: 'Ứng lương',
                    value: countUngLuong.toString(),
                    color: Colors.deepOrange,
                    page: UngLuongListDesktop(
                      idCongTrinh: widget.congTrinh.id!,
                      tenCongTrinh: widget.congTrinh.ten,
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
                widget.congTrinh.ten,
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
    final progress = widget.congTrinh.tienDo ?? 0;
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
      child: widget.congTrinh.hinhAnh != null &&
          widget.congTrinh.hinhAnh!.isNotEmpty &&
          File(widget.congTrinh.hinhAnh!).existsSync()
          ? Image.file(
        File(widget.congTrinh.hinhAnh!),
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
            widget.congTrinh.diaChi ?? 'Chưa có địa chỉ',
          ),

          const SizedBox(height: 16),

          _infoRow(
            Icons.calendar_today_outlined,
            'Ngày bắt đầu',
            widget.congTrinh.ngayBatDau ?? 'Chưa có',
          ),

          if (widget.congTrinh.ngayKetThuc != null &&
              widget.congTrinh.ngayKetThuc!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _infoRow(
              Icons.event_available_outlined,
              'Ngày kết thúc',
              widget.congTrinh.ngayKetThuc!,
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
    final progress = (widget.congTrinh.tienDo ?? 0).clamp(0, 100);
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
            widget.congTrinh.moTa?.isNotEmpty == true
                ? widget.congTrinh.moTa!
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
