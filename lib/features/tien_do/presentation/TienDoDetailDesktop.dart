import 'package:flutter/material.dart';

import '../../../core/utils/SyncColor.dart';
import '../../../data/models/TienDoCongTrinhModel.dart';

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
            _buildHeader(context),

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
                        _buildOverview(),

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

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          _iconButton(
            icon: Icons.arrow_back,
            tooltip: 'Quay lại',
            onPressed: onBack ??
                    () {
                  Navigator.pop(context);
                },
          ),

          const SizedBox(width: 16),

          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xff2563eb)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color: Color(0xff2563eb),
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
                const Text(
                  'Chi tiết tiến độ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff1e293b),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  model.tenCongViec,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          if (onEdit != null) ...[
            OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(
                Icons.edit_outlined,
                size: 18,
              ),
              label: const Text('Sửa'),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                const Color(0xff2563eb),
                side: const BorderSide(
                  color: Color(0xff2563eb),
                ),
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],

          if (onDelete != null) ...[
            const SizedBox(width: 10),

            OutlinedButton.icon(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline,
                size: 18,
              ),
              label: const Text('Xóa'),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                const Color(0xffdc2626),
                side: const BorderSide(
                  color: Color(0xffdc2626),
                ),
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // OVERVIEW
  // ============================================================

  Widget _buildOverview() {
    final progress =
    (model.phanTramThucTe ?? 0)
        .clamp(0, 100)
        .toDouble();

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 3,
          child: _card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: progressColor
                              .withOpacity(0.1),
                          borderRadius:
                          BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.work_outline,
                          color: progressColor,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Text(
                          model.tenCongViec,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight:
                            FontWeight.w700,
                            color:
                            Color(0xff1e293b),
                          ),
                        ),
                      ),

                      SyncColor.icon(
                        model.isSynced,
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  _statusBadge(),

                  if (isTreDeadline) ...[
                    const SizedBox(height: 14),
                    _warningBox(),
                  ],
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 18),

        Expanded(
          flex: 2,
          child: _card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Tiến độ thực tế',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                            FontWeight.w600,
                            color:
                            Color(0xff64748b),
                          ),
                        ),
                      ),

                      Text(
                        '${progress.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight:
                          FontWeight.w800,
                          color: progressColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 12,
                      backgroundColor:
                      const Color(0xffe2e8f0),
                      color: progressColor,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0%',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                          Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        '100%',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                          Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INFORMATION
  // ============================================================

  Widget _buildInformation() {
    return _card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _sectionHeader(
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
                    _formatDate(model.ngayBatDau),
                  ),
                ),

                Expanded(
                  child: _infoItem(
                    icon: Icons.event_outlined,
                    label: 'Ngày kết thúc',
                    value:
                    _formatDate(model.ngayKetThuc),
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

    return _card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _sectionHeader(
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
    return _card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              icon: Icons.timeline_outlined,
              title: 'Tiến trình thực hiện',
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                _timelineItem(
                  icon: Icons.play_circle_outline,
                  title: 'Bắt đầu',
                  value:
                  _formatDate(model.ngayBatDau),
                  color:
                  const Color(0xff2563eb),
                ),

                _timelineLine(),

                _timelineItem(
                  icon: statusIcon,
                  title: 'Hiện tại',
                  value:
                  '${(model.phanTramThucTe ?? 0).toStringAsFixed(0)}%',
                  color: progressColor,
                ),

                _timelineLine(),

                _timelineItem(
                  icon: Icons.flag_outlined,
                  title: 'Kết thúc',
                  value:
                  _formatDate(model.ngayKetThuc),
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

  Widget _card({
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xffe5e7eb),
        ),
      ),
      child: child,
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color:
            const Color(0xff2563eb)
                .withOpacity(0.1),
            borderRadius:
            BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 19,
            color: const Color(0xff2563eb),
          ),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xff1e293b),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: progressColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 17,
            color: progressColor,
          ),

          const SizedBox(width: 7),

          Text(
            statusText,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: progressColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _warningBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xfffff1f2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xfffecdd3),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xffdc2626),
            size: 20,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'Công việc đã quá hạn nhưng chưa hoàn thành.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xffb91c1c),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _timelineItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 21,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xff64748b),
          ),
        ),

        const SizedBox(height: 3),

        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
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

  Widget _iconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xffe2e8f0),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xff475569),
          ),
        ),
      ),
    );
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) {
      return '--';
    }

    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}