import 'package:flutter/material.dart';

import '../../../data/models/TienDoCongTrinhModel.dart';
import 'buildHeader.dart';
import 'buildOverview.dart';
import 'card.dart';
import 'formatDate.dart';
import 'sectionHeader.dart';
import 'timelineItem.dart';

class TienDoDetailDesktop extends StatelessWidget {
  final TienDoCongTrinhModel model;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onBack;

  const TienDoDetailDesktop({
    super.key,
    required this.model,
    this.onEdit,
    this.onDelete,
    this.onBack,
  });

  bool get isTreDeadline {
    if (model.ngayKetThuc == null ||
        model.ngayKetThuc!.isEmpty) {
      return false;
    }

    final deadline = DateTime.tryParse(
      model.ngayKetThuc!,
    );

    if (deadline == null) return false;

    return DateTime.now().isAfter(deadline) &&
        (model.phanTramThucTe ?? 0) < 100;
  }

  Color get progressColor {
    if (isTreDeadline) {
      return const Color(0xffdc2626);
    }

    switch (model.trangThai) {
      case 2:
        return const Color(0xff16a34a);

      case 1:
        return const Color(0xfff59e0b);

      default:
        return const Color(0xff64748b);
    }
  }

  String get statusText {
    if (isTreDeadline) {
      return 'Trễ tiến độ';
    }

    switch (model.trangThai) {
      case 2:
        return 'Hoàn thành';

      case 1:
        return 'Đang thực hiện';

      default:
        return 'Chưa thực hiện';
    }
  }

  IconData get statusIcon {
    if (isTreDeadline) {
      return Icons.warning_amber_rounded;
    }

    switch (model.trangThai) {
      case 2:
        return Icons.check_circle_outline;

      case 1:
        return Icons.pending_actions_outlined;

      default:
        return Icons.radio_button_unchecked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      body: SafeArea(
        child: Column(
          children: [
            buildHeader(context, model, onEdit, onDelete, onBack),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  28,
                  24,
                  28,
                  40,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1200,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                      children: [
                        buildOverview(model, progressColor,
                           isTreDeadline,
                           statusIcon,
                           statusText),

                        const SizedBox(height: 18),

                        _buildInformation(),

                        const SizedBox(height: 18),

                        _buildDescription(),

                        const SizedBox(height: 18),

                        _buildTimeline(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================


  // ============================================================
  // OVERVIEW
  // ============================================================



  // ============================================================
  // INFORMATION
  // ============================================================

  Widget _buildInformation() {
    return card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            sectionHeader(
              icon: Icons.info_outline,
              title: 'Thông tin công việc',
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: _infoItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Ngày bắt đầu',
                    value:
                    formatDate(model.ngayBatDau),
                  ),
                ),

                Expanded(
                  child: _infoItem(
                    icon: Icons.event_outlined,
                    label: 'Ngày kết thúc',
                    value:
                    formatDate(model.ngayKetThuc),
                    valueColor: isTreDeadline
                        ? const Color(0xffdc2626)
                        : null,
                  ),
                ),

                Expanded(
                  child: _infoItem(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Trọng số',
                    value:
                    '${model.trongSo ?? 1}',
                  ),
                ),

                Expanded(
                  child: _infoItem(
                    icon: statusIcon,
                    label: 'Trạng thái',
                    value: statusText,
                    valueColor: progressColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DESCRIPTION
  // ============================================================

  Widget _buildDescription() {
    final description =
        model.moTa?.trim() ?? '';

    return card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            sectionHeader(
              icon: Icons.description_outlined,
              title: 'Mô tả công việc',
            ),

            const SizedBox(height: 18),

            if (description.isEmpty)
              Text(
                'Chưa có mô tả cho công việc này.',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xfff8fafc),
                  borderRadius:
                  BorderRadius.circular(8),
                  border: Border.all(
                    color:
                    const Color(0xffe2e8f0),
                  ),
                ),
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xff475569),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TIMELINE
  // ============================================================

  Widget _buildTimeline() {
    return card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            sectionHeader(
              icon: Icons.timeline_outlined,
              title: 'Tiến trình thực hiện',
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                timelineItem(
                  icon: Icons.play_circle_outline,
                  title: 'Bắt đầu',
                  value:
                  formatDate(model.ngayBatDau),
                  color:
                  const Color(0xff2563eb),
                ),

                _timelineLine(),

                timelineItem(
                  icon: statusIcon,
                  title: 'Hiện tại',
                  value:
                  '${(model.phanTramThucTe ?? 0).toStringAsFixed(0)}%',
                  color: progressColor,
                ),

                _timelineLine(),

                timelineItem(
                  icon: Icons.flag_outlined,
                  title: 'Kết thúc',
                  value:
                  formatDate(model.ngayKetThuc),
                  color:
                  const Color(0xff64748b),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // COMPONENTS
  // ============================================================


  Widget _infoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xff64748b),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xff64748b),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                value,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: valueColor ??
                      const Color(0xff1e293b),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }



  Widget _timelineLine() {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(
          left: 14,
          right: 14,
          bottom: 32,
        ),
        color: const Color(0xffe2e8f0),
      ),
    );
  }
}