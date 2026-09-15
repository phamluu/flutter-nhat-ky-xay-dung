import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';
import '../../../../../core/utils/SyncColor.dart';
import '../../../data/models/NhanVienCongTrinh.dart';
import '../../../data/services/nhan_vien_cong_trinh_service.dart';
import 'nhanh_vien_cong_trinh_form_desktop.dart';

class NhanVienCongTrinhListDesktop extends StatefulWidget {
  final int? idCongTrinh;
  final String? tenCongTrinh;

  const NhanVienCongTrinhListDesktop({
    super.key,
    this.idCongTrinh,
    this.tenCongTrinh,
  });

  @override
  State<NhanVienCongTrinhListDesktop> createState() => _NhanVienCongTrinhListDesktopState();
}

class _NhanVienCongTrinhListDesktopState extends State<NhanVienCongTrinhListDesktop> {
  late final NhanVienCongTrinhService _service;

  late Future<List<NhanVienCongTrinh>> _future;

  @override
  void initState() {
    super.initState();
    _service = NhanVienCongTrinhService();
    _reload();
  }

  void _reload() {
    _future = _service.getByCongTrinh(widget.idCongTrinh);
  }

  Future<void> _openForm({
    NhanVienCongTrinh? nhanVienCongTrinh,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NhanhVienCongTrinhFormDesktop(
          item: nhanVienCongTrinh,
          idCongTrinh: widget.idCongTrinh,
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _reload();
      });
    }
  }

  Future<void> _deleteItem( NhanVienCongTrinh item, ) async {
    final tenNhanVien = item.nhanVien?.hoTen ?? "nhân viên này";
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: Text(
            "Bạn có chắc muốn xóa '$tenNhanVien' "
                "khỏi công trình?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
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
      await _service.delete(item.id!);

      if (!mounted) return;
showSuccessToast(context, "Đã xóa nhân viên khỏi công trình");

      setState(() {
        _reload();
      });
    } catch (e) {
      if (!mounted) return;
showErrorToast(context, e, "Lỗi khi xóa: ");

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
          ],
        ),
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
                child: FutureBuilder<List<NhanVienCongTrinh>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      return _buildError( snapshot.error.toString(), );
                    }

                    final data = snapshot.data ?? [];

                    if (data.isEmpty) {
                      return _buildEmpty();
                    }

                    return _buildDataContent(data);
                  },
                ),
              ),
            ],
          ),
        ),
      )
    );

  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.people_outline,
            color: Colors.blue.shade700,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                "Nhân viên công trình",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff263238),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                widget.tenCongTrinh?.isNotEmpty == true
                    ? widget.tenCongTrinh!
                    : "Danh sách nhân viên",
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

        ElevatedButton.icon(
          onPressed: () => _openForm(),
          icon: const Icon(
            Icons.add,
            size: 19,
          ),
          label: const Text(
            "Thêm nhân viên",
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 13,
            ),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DATA
  // ============================================================

  Widget _buildDataContent(
      List<NhanVienCongTrinh> data,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        _buildSummary(data),

        const SizedBox(height: 18),

        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 750) {
                return _buildMobileCards(data);
              }

              return _buildDesktopTable(data);
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(
      List<NhanVienCongTrinh> data,
      ) {
    return Row(
      children: [
        _summaryCard(
          icon: Icons.people_outline,
          title: "Nhân viên",
          value: data.length.toString(),
          color: Colors.blue,
        ),

        const SizedBox(width: 14),

        _summaryCard(
          icon: Icons.work_outline,
          title: "Công trình",
          value: "1",
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DESKTOP TABLE
  // ============================================================

  Widget _buildDesktopTable(
      List<NhanVienCongTrinh> data,
      ) {
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
          _buildTableHeader(),

          const Divider(
            height: 1,
          ),

          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return _buildTableRow(
                  data[index],
                  index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      decoration: const BoxDecoration(
        color: Color(0xfffafbfc),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 55,
            child: _headerText("STT"),
          ),

          Expanded(
            flex: 4,
            child: _headerText("NHÂN VIÊN"),
          ),

          Expanded(
            flex: 3,
            child: _headerText("VAI TRÒ"),
          ),

          Expanded(
            flex: 3,
            child: _headerText("SỐ ĐIỆN THOẠI"),
          ),

          SizedBox(
            width: 100,
            child: _headerText(
              "ĐỒNG BỘ",
            ),
          ),

          SizedBox(
            width: 100,
            child: _headerText(
              "THAO TÁC",
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade600,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTableRow( NhanVienCongTrinh item, int index, ) {
    final hoTen = item?.tenNhanVien ?? "Chưa đặt tên";
    final vaiTro =item.vaiTro?.isNotEmpty == true ? item.vaiTro! : "-";
    final phone = item.soDienThoai?.isNotEmpty == true ? item.soDienThoai! : "-";
    return Container(
      constraints: const BoxConstraints(
        minHeight: 76,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade100,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 55,
            child: Text(
              "${index + 1}",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),

          Expanded(
            flex: 4,
            child: Row(
              children: [
                _avatar(hoTen),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hoTen,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 3,
            child: _roleBadge(vaiTro),
          ),

          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 17,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 7),
                Text(
                  phone,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: 100,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SyncColor.icon(
                item.isSynced,
              ),
            ),
          ),

          SizedBox(
            width: 100,
            child: Row(
              children: [
                _actionButton(
                  icon: Icons.edit_outlined,
                  color: Colors.blue,
                  tooltip: "Sửa",
                  onPressed: () {
                    _openForm(
                      nhanVienCongTrinh: item,
                    );
                  },
                ),

                const SizedBox(width: 6),

                _actionButton(
                  icon: Icons.delete_outline,
                  color: Colors.red,
                  tooltip: "Xóa",
                  onPressed: () {
                    _deleteItem(item);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE / SMALL DESKTOP
  // ============================================================

  Widget _buildMobileCards(
      List<NhanVienCongTrinh> data,
      ) {
    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (_, __) =>
      const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = data[index];

        return _buildEmployeeCard(
          item,
          index,
        );
      },
    );
  }

  Widget _buildEmployeeCard( NhanVienCongTrinh item, int index,) {
    final hoTen =
        item.nhanVien?.hoTen ?? "Chưa đặt tên";
    final phone = item.nhanVien?.soDienThoai ?? "N/A";
    final vaiTro = item.vaiTro?.isNotEmpty == true ? item.vaiTro! : "-";
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _avatar(hoTen),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${index + 1}. $hoTen",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _roleBadge(vaiTro),
                  ],
                ),
              ),

              SyncColor.icon( item.isSynced,),
            ],
          ),

          const SizedBox(height: 14),

          const Divider(
            height: 1,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: 17,
                color: Colors.grey.shade500,
              ),

              const SizedBox(width: 8),

              Text(
                phone,
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),

              const Spacer(),

              _actionButton(
                icon: Icons.edit_outlined,
                color: Colors.blue,
                tooltip: "Sửa",
                onPressed: () {
                  _openForm(
                    nhanVienCongTrinh: item,
                  );
                },
              ),

              const SizedBox(width: 6),

              _actionButton(
                icon: Icons.delete_outline,
                color: Colors.red,
                tooltip: "Xóa",
                onPressed: () {
                  _deleteItem(item);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMPONENTS
  // ============================================================

  Widget _avatar(String name) {
    final firstLetter =
    name.trim().isNotEmpty
        ? name.trim()[0].toUpperCase()
        : "?";

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Text(
        firstLetter,
        style: TextStyle(
          color: Colors.blue.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _roleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.blue.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
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
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(
            icon,
            size: 18,
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
    return Center(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
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
                Icons.people_outline,
                size: 34,
                color: Colors.blue.shade400,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "Chưa có nhân viên",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              "Chưa có nhân viên nào được phân công "
                  "vào công trình này.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text(
                "Thêm nhân viên",
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

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 45,
            color: Colors.red.shade300,
          ),

          const SizedBox(height: 12),

          const Text(
            "Không thể tải danh sách nhân viên",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            error,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 15),

          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _reload();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Thử lại"),
          ),
        ],
      ),
    );
  }
}