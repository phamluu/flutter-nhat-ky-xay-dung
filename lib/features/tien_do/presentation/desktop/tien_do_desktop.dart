import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/tien_do/presentation/TienDoDetailDesktop.dart';

import '../../../../core/utils/SyncColor.dart';
import '../../../../data/models/TienDoCongTrinhModel.dart';
import '../../../../data/repositories/TienDoRepository.dart';
import '../../../../services/TienDoService.dart';
import '../../../cong_trinh/data/models/summaryCard.dart';
import '../../TienDoFormScreen.dart';
import 'tien_do_form_desktop.dart';

class TienDoDesktop extends StatefulWidget {
  final int idCongTrinh;
  final String? tenCongTrinh;

  const TienDoDesktop({
    super.key,
    required this.idCongTrinh,
    this.tenCongTrinh,
  });

  @override
  State<TienDoDesktop> createState() => _TienDoScreenState();
}

class _TienDoScreenState extends State<TienDoDesktop> {
  final service = TienDoService(TienDoRepository());

  List<TienDoCongTrinhModel> list = [];

  bool isLoading = true;

  String searchText = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> loadData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final data = await service.getList(
        widget.idCongTrinh,
      );

      if (!mounted) return;

      setState(() {
        list = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể tải dữ liệu: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<TienDoCongTrinhModel> get filteredList {
    if (searchText.trim().isEmpty) {
      return list;
    }

    final keyword = searchText.toLowerCase().trim();

    return list.where((item) {
      return item.tenCongViec.toLowerCase().contains(keyword);
    }).toList();
  }

  // ============================================================
  // ADD
  // ============================================================

  Future<void> addItem() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TienDoFormDesktop(
          idCongTrinh: widget.idCongTrinh,
        ),
      ),
    );

    loadData();
  }

  // ============================================================
  // EDIT
  // ============================================================
  Future<void> viewItem(TienDoCongTrinhModel item,) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TienDoDetailDesktop(
          model: item,
        ),
      ),
    );
  }
  Future<void> editItem(
    TienDoCongTrinhModel item,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TienDoFormDesktop(
          idCongTrinh: widget.idCongTrinh,
          model: item,
        ),
      ),
    );

    loadData();
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteItem(
    TienDoCongTrinhModel item,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Xóa công việc?',
          ),
          content: Text(
            'Bạn có chắc muốn xóa "${item.tenCongViec}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffdc2626),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    // Widget có thể đã bị dispose trong lúc dialog đang mở
    if (!mounted) return;

    if (confirm != true) return;

    try {
      await service.delete(item.id!);

      // Widget có thể đã bị dispose trong lúc delete
      if (!mounted) return;

      await loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Xóa công việc thành công',
          ),
          backgroundColor: Colors.green,
        ),
      );
      // loadData() cũng có async
      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể xóa: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f8),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xffe5e7eb),
          ),
        ),
      ),
      child: Row(
        children: [
          _iconButton(
            icon: Icons.arrow_back,
            tooltip: 'Quay lại',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 16),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xffeff6ff),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.timeline,
              color: Color(0xff2563eb),
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tiến độ công trình',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff1f2937),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.tenCongTrinh ?? 'Quản lý tiến độ công việc',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: loadData,
            icon: const Icon(
              Icons.refresh,
              size: 18,
            ),
            label: const Text('Làm mới'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xff475569),
              side: const BorderSide(
                color: Color(0xffd1d5db),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: addItem,
            icon: const Icon(
              Icons.add,
              size: 19,
            ),
            label: const Text(
              'Thêm công việc',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff2563eb),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1450,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSummary(),
                  const SizedBox(height: 22),
                  _buildListCard(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary() {
    final total = list.length;

    final doing = list
        .where(
          (e) => e.trangThai == 1,
        )
        .length;

    final completed = list
        .where(
          (e) => e.trangThai == 2,
        )
        .length;

    final average = total == 0
        ? 0
        : list.fold<double>(
              0,
              (sum, item) => sum + (item.phanTramThucTe ?? 0),
            ) /
            total;

    final overdue = list
        .where(
          _isTreDeadline,
        )
        .length;

    final items = [
      SummaryData(
        icon: Icons.assignment_outlined,
        title: 'Tổng công việc',
        value: '$total',
        subtitle: 'Công việc',
        iconColor: const Color(0xff2563eb),
        backgroundColor: const Color(0xffeff6ff),
      ),
      SummaryData(
        icon: Icons.pending_actions_outlined,
        title: 'Đang thực hiện',
        value: '$doing',
        subtitle: 'Công việc',
        iconColor: const Color(0xffd97706),
        backgroundColor: const Color(0xfffffbeb),
      ),
      SummaryData(
        icon: Icons.check_circle_outline,
        title: 'Hoàn thành',
        value: '$completed',
        subtitle: 'Công việc',
        iconColor: const Color(0xff16a34a),
        backgroundColor: const Color(0xfff0fdf4),
      ),
      SummaryData(
        icon: Icons.speed_outlined,
        title: 'Tiến độ trung bình',
        value: '${average.round()}%',
        subtitle: 'Toàn công trình',
        iconColor: const Color(0xff7c3aed),
        backgroundColor: const Color(0xfff5f3ff),
      ),
      SummaryData(
        icon: Icons.warning_amber_outlined,
        title: 'Trễ hạn',
        value: '$overdue',
        subtitle: 'Công việc',
        iconColor: const Color(0xffdc2626),
        backgroundColor: const Color(0xfffff1f2),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Desktop rộng
        if (width >= 1200) {
          return Row(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                Expanded(
                  child: _summaryCard(
                    data: items[i],
                  ),
                ),
                if (i != items.length - 1) const SizedBox(width: 16),
              ],
            ],
          );
        }

        // Desktop vừa / cửa sổ bị thu nhỏ
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: items.map((item) {
            return SizedBox(
              width: width >= 800
                  ? (width - 32) / 3
                  : width >= 500
                      ? (width - 16) / 2
                      : width,
              child: _summaryCard(
                data: item,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard({
    required SummaryData data,
  }) {
    return Container(
      height: 112,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xffe5e7eb),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: data.backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              data.icon,
              color: data.iconColor,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // QUAN TRỌNG:
          // Expanded giúp Column không vượt khỏi card.
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // QUAN TRỌNG:
                    // Không để Text value + subtitle tự lấy width.
                    Flexible(
                      child: Text(
                        data.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff1f2937),
                        ),
                      ),
                    ),

                    const SizedBox(width: 5),

                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 3,
                        ),
                        child: Text(
                          data.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LIST CARD
  // ============================================================

  Widget _buildListCard() {
    final data = filteredList;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xffe5e7eb),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildListHeader(),
          const Divider(
            height: 1,
            color: Color(0xffe5e7eb),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(50),
              child: CircularProgressIndicator(),
            )
          else if (data.isEmpty)
            _buildEmptyState()
          else
            _buildTable(data),
        ],
      ),
    );
  }

  // ============================================================
  // LIST HEADER
  // ============================================================

  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Danh sách công việc',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff1f2937),
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Theo dõi tiến độ thực tế của từng công việc',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xff64748b),
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 280,
            height: 38,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm công việc...',
                hintStyle: const TextStyle(
                  fontSize: 12,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 18,
                ),
                filled: true,
                fillColor: const Color(0xfff8fafc),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xffe2e8f0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xffe2e8f0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xff2563eb),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE
  // ============================================================

  Widget _buildTable(
    List<TienDoCongTrinhModel> data,
  ) {
    return Column(
      children: [
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          color: const Color(0xfff8fafc),
          child: const Row(
            children: [
              SizedBox(
                width: 55,
                child: Text(
                  '#',
                  style: _tableHeaderStyle,
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'CÔNG VIỆC',
                  style: _tableHeaderStyle,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'DEADLINE',
                  style: _tableHeaderStyle,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'TIẾN ĐỘ',
                  style: _tableHeaderStyle,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'TRẠNG THÁI',
                  style: _tableHeaderStyle,
                ),
              ),
              SizedBox(
                width: 100,
                child: Text(
                  'THAO TÁC',
                  textAlign: TextAlign.right,
                  style: _tableHeaderStyle,
                ),
              ),
            ],
          ),
        ),
        ...List.generate(
          data.length,
          (index) {
            return _buildTableRow(
              data[index],
              index,
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // TABLE ROW
  // ============================================================

  Widget _buildTableRow(
    TienDoCongTrinhModel item,
    int index,
  ) {
    final progress = (item.phanTramThucTe ?? 0).clamp(0, 100);

    final color = _getColor(item);

    return Container(
      constraints: const BoxConstraints(
        minHeight: 82,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xfff0f1f3),
          ),
        ),
      ),
      child: Row(
        children: [
          // INDEX
          SizedBox(
            width: 55,
            child: Text(
              '${index + 1}'.padLeft(2, '0'),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // NAME
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.construction_outlined,
                    size: 17,
                    color: color,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.tenCongViec,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff1f2937),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          SyncColor.icon(
                            item.isSynced,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.isSynced != null
                                ? 'Đã đồng bộ'
                                : 'Chưa đồng bộ',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // DEADLINE
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(
                  _isTreDeadline(item)
                      ? Icons.warning_amber_rounded
                      : Icons.calendar_today_outlined,
                  size: 16,
                  color: _isTreDeadline(item)
                      ? const Color(0xffdc2626)
                      : const Color(0xff64748b),
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    _formatDate(
                      item.ngayKetThuc,
                    ),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: _isTreDeadline(item)
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: _isTreDeadline(item)
                          ? const Color(0xffdc2626)
                          : const Color(0xff475569),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // PROGRESS
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            minHeight: 7,
                            backgroundColor: const Color(0xffe5e7eb),
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 38,
                        child: Text(
                          '$progress%',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // STATUS
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _statusBadge(item),
            ),
          ),

          // ACTIONS
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _rowActionButton(
                  icon: Icons.remove_red_eye,
                  tooltip: 'Xem',
                  color: const Color(0xff2563eb),
                  onPressed: () {
                    viewItem(item);
                  },
                ),
                const SizedBox(width: 6),
                _rowActionButton(
                  icon: Icons.edit_outlined,
                  tooltip: 'Chỉnh sửa',
                  color: const Color(0xff2563eb),
                  onPressed: () {
                    editItem(item);
                  },
                ),
                const SizedBox(width: 6),
                _rowActionButton(
                  icon: Icons.delete_outline,
                  tooltip: 'Xóa',
                  color: const Color(0xffdc2626),
                  onPressed: () {
                    deleteItem(item);
                  },
                ),
              ],
            ),
          )

        ],
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(
    TienDoCongTrinhModel item,
  ) {
    final color = _getColor(item);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _isTreDeadline(item) ? 'Trễ hạn' : _getStatusText(item.trangThai),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // ============================================================
  // ROW ACTION
  // ============================================================

  Widget _rowActionButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(
            icon,
            size: 17,
            color: color,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(60),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xfff1f5f9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 30,
              color: Color(0xff94a3b8),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Chưa có công việc',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xff334155),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            searchText.isEmpty
                ? 'Hãy thêm công việc đầu tiên cho công trình.'
                : 'Không tìm thấy công việc phù hợp.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          if (searchText.isEmpty) ...[
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: addItem,
              icon: const Icon(
                Icons.add,
                size: 18,
              ),
              label: const Text(
                'Thêm công việc',
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool _isTreDeadline(
    TienDoCongTrinhModel item,
  ) {
    if (item.ngayKetThuc == null) {
      return false;
    }

    final deadline = DateTime.tryParse(
      item.ngayKetThuc!,
    );

    if (deadline == null) {
      return false;
    }

    return DateTime.now().isAfter(deadline) && (item.phanTramThucTe ?? 0) < 100;
  }

  Color _getColor(
    TienDoCongTrinhModel item,
  ) {
    if (_isTreDeadline(item)) {
      return const Color(0xffdc2626);
    }

    switch (item.trangThai) {
      case 2:
        return const Color(0xff16a34a);

      case 1:
        return const Color(0xffd97706);

      default:
        return const Color(0xff64748b);
    }
  }

  String _getStatusText(
    int? status,
  ) {
    switch (status) {
      case 2:
        return 'Hoàn thành';

      case 1:
        return 'Đang làm';

      default:
        return 'Chưa làm';
    }
  }

  String _formatDate(
    String? date,
  ) {
    if (date == null || date.isEmpty) {
      return '--';
    }

    final parsed = DateTime.tryParse(date);

    if (parsed == null) {
      return date;
    }

    return '${parsed.day.toString().padLeft(2, '0')}/'
        '${parsed.month.toString().padLeft(2, '0')}/'
        '${parsed.year}';
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xfff8fafc),
            borderRadius: BorderRadius.circular(8),
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

  static const TextStyle _tableHeaderStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: Color(0xff64748b),
    letterSpacing: 0.3,
  );
}
