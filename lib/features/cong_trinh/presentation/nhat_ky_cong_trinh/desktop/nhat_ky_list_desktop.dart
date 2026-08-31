import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';
import '../../../../../core/utils/SyncColor.dart';
import '../../../data/models/NhatKyCongTrinh.dart';
import '../../../data/services/nhat_ky_service.dart';
import '../widgets/weather_dropdown.dart';
import 'nhat_ky_detail_desktop.dart';
import 'nhat_ky_form_desktop.dart';

class NhatKyListDesktop extends StatefulWidget {
  final int? idCongTrinh;
  final String? tenCongTrinh;

  const NhatKyListDesktop({
    super.key,
    this.idCongTrinh,
    this.tenCongTrinh,
  });

  @override
  State<NhatKyListDesktop> createState() => _NhatKyListDesktopState();
}

class _NhatKyListDesktopState extends State<NhatKyListDesktop> {
  late final NhatKyService _service;
  late Future<List<NhatKyViewModel>> _future;

  @override
  void initState() {
    super.initState();

    _service = NhatKyService();

    _future = _service.getAllNhatKy(
      widget.idCongTrinh,
    );
  }

  // ============================================================
  // RELOAD
  // ============================================================

  void _reload() {
    setState(() {
      _future = _service.getAllNhatKy(
        widget.idCongTrinh,
      );
    });
  }

  // ============================================================
  // ADD / EDIT
  // ============================================================

  Future<void> _openForm({ NhatKyCongTrinh? nhatKy, }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NhatKyFormDesktop(
          nhatKy: nhatKy,
          idCongTrinh: widget.idCongTrinh,
        ),
      ),
    );

    if (result == true && mounted) {
      _reload();
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteNhatKy( NhatKyCongTrinh nhatKy,) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            "Xác nhận xóa",
          ),
          content: Text(
            "Bạn có chắc muốn xóa nhật ký "
                "'${nhatKy.tenNhatKy ?? "Chưa đặt tên"}'?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
              child: const Text("Hủy"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(ctx, true);
              },
              child: const Text("Xóa"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;
    try {
      await _service.deleteNhatKy(nhatKy.id!,);
      if (!mounted) return;
        showSuccessToast(context, "Đã xóa nhật ký");
      _reload();
    } catch (e) {
      if (!mounted) return;
        showErrorToast(context, e, "Lỗi khi xóa: ");
    }
  }

  // ============================================================
  // DETAIL
  // ============================================================

  Future<void> _openDetail( NhatKyCongTrinh nhatKy, ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NhatKyDetailDesktop(
          nhatKy: nhatKy,
        ),
      ),
    );

    if (result == true && mounted) {
      _reload();
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildHeader(),
      ),
      body: Container(
        color: const Color(0xfff5f6f8),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Nhật ký công trình",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff263238),
                ),
              ),

              const SizedBox(height: 6),

              if (widget.tenCongTrinh != null &&
                  widget.tenCongTrinh!.trim().isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.business_outlined,
                      size: 17,
                      color: Colors.grey.shade600,
                    ),

                    const SizedBox(width: 7),

                    Text(
                      widget.tenCongTrinh!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        FilledButton.icon(
          onPressed: () {
            _openForm();
          },
          icon: const Icon(
            Icons.add,
            size: 19,
          ),
          label: const Text(
            "Thêm nhật ký",
          ),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent() {
    return FutureBuilder<List<NhatKyViewModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return _buildError( snapshot.error, );
        }
        final data = snapshot.data ?? [];
        if (data.isEmpty) {
          return _buildEmpty();
        }
        return _buildTable(data);
      },
    );
  }

  // ============================================================
  // TABLE
  // ============================================================

  Widget _buildTable( List<NhatKyViewModel> data,) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: ListView.separated(
              itemCount: data.length,
              separatorBuilder: (_, __) {
                return Divider(
                  height: 1,
                  color: Colors.grey.shade200,
                );
              },
              itemBuilder: (context, index) {
                return _buildTableRow( data[index], index, );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE HEADER
  // ============================================================

  Widget _buildTableHeader() {
    return Container(
      height: 52,

      color: const Color(0xfffafafa),

      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),

      child: Row(
        children: [
          _headerCell(
            "#",
            width: 50,
          ),

          _headerCell(
            "TÊN NHẬT KÝ",
            flex: 3,
          ),

          _headerCell(
            "NGÀY TRIỂN KHAI",
            flex: 2,
          ),

          _headerCell(
            "THỜI TIẾT",
            flex: 2,
          ),

          _headerCell(
            "CÔNG NHÂN",
            flex: 1,
          ),

          _headerCell(
            "ĐỒNG BỘ",
            width: 70,
          ),

          _headerCell(
            "THAO TÁC",
            width: 120,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _headerCell(
      String text, {
        int? flex,
        double? width,
        TextAlign align = TextAlign.left,
      }) {
    final child = Text(
      text,
      textAlign: align,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade600,
        letterSpacing: 0.3,
      ),
    );

    if (width != null) {
      return SizedBox(
        width: width,
        child: child,
      );
    }

    return Expanded(
      flex: flex ?? 1,
      child: child,
    );
  }

  // ============================================================
  // TABLE ROW
  // ============================================================

  Widget _buildTableRow( NhatKyViewModel item, int index, ) {
    final nk = item.nhatKy;
    return InkWell(
      onTap: () {
        _openDetail(nk);
      },
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 92,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),

        child: Row(
          children: [
            // STT
            SizedBox(
              width: 50,
              child: Text(
                "${index + 1}",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),

            // TÊN
            Expanded(
              flex: 3,
              child: _buildNameCell(nk),
            ),

            // NGÀY
            Expanded(
              flex: 2,
              child: _buildDateCell(nk),
            ),

            // THỜI TIẾT
            Expanded(
              flex: 2,
              child: _buildWeatherCell(nk),
            ),

            // CÔNG NHÂN
            Expanded(
              flex: 1,
              child: _buildWorkerCell(
                item.soLuongCongNhan,
              ),
            ),

            // SYNC
            SizedBox(
              width: 70,
              child: Center(
                child: SyncColor.icon(
                  nk.isSynced,
                ),
              ),
            ),

            // ACTION
            SizedBox(
              width: 120,
              child: _buildActions(nk),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NAME
  // ============================================================

  Widget _buildNameCell(
      NhatKyCongTrinh nk,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        Text(
          nk.tenNhatKy ?? "Chưa đặt tên",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xff263238),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          "Nhật ký xây dựng",
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  Widget _buildDateCell(
      NhatKyCongTrinh nk,
      ) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: 16,
          color: Colors.redAccent.shade200,
        ),

        const SizedBox(width: 7),

        Expanded(
          child: Text(
            "${nk.ngayTrienKhai ?? ""}",
            style: const TextStyle(
              fontSize: 13,
              color: Colors.redAccent,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // WEATHER
  // ============================================================

  Widget _buildWeatherCell(
      NhatKyCongTrinh nk,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        buildWeatherInfo(
          "Sáng",
          nk.thoiTietSang,
        ),

        const SizedBox(height: 3),

        buildWeatherInfo(
          "Chiều",
          nk.thoiTietChieu,
        ),
      ],
    );
  }

  // ============================================================
  // WORKER
  // ============================================================

  Widget _buildWorkerCell(
      dynamic soLuongCongNhan,
      ) {
    return Row(
      children: [
        Icon(
          Icons.people_outline,
          size: 17,
          color: Colors.grey.shade600,
        ),

        const SizedBox(width: 6),

        Text(
          "$soLuongCongNhan",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Widget _buildActions(
      NhatKyCongTrinh nk,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        _actionButton(
          icon: Icons.visibility_outlined,
          color: Colors.grey.shade700,
          tooltip: "Xem chi tiết",
          onPressed: () {
            _openDetail(nk);
          },
        ),

        const SizedBox(width: 5),

        _actionButton(
          icon: Icons.edit_outlined,
          color: Colors.blue.shade700,
          tooltip: "Chỉnh sửa",
          onPressed: () {
            _openForm(
              nhatKy: nk,
            );
          },
        ),

        const SizedBox(width: 5),

        _actionButton(
          icon: Icons.delete_outline,
          color: Colors.red.shade600,
          tooltip: "Xóa",
          onPressed: () {
            _deleteNhatKy(nk);
          },
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,

      child: InkWell(
        borderRadius: BorderRadius.circular(7),

        onTap: onPressed,

        child: Container(
          width: 32,
          height: 32,

          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
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

  Widget _buildEmpty() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              width: 70,
              height: 70,

              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.menu_book_outlined,
                size: 34,
                color: Colors.blue.shade600,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Chưa có nhật ký nào",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Hãy thêm nhật ký đầu tiên cho công trình.",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 18),

            FilledButton.icon(
              onPressed: () {
                _openForm();
              },
              icon: const Icon(
                Icons.add,
                size: 18,
              ),
              label: const Text(
                "Thêm nhật ký",
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
      Object? error,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(
              Icons.error_outline,
              size: 45,
              color: Colors.red.shade400,
            ),

            const SizedBox(height: 12),

            const Text(
              "Không thể tải danh sách nhật ký",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "$error",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 15),

            OutlinedButton.icon(
              onPressed: _reload,
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                "Thử lại",
              ),
            ),
          ],
        ),
      ),
    );
  }
}