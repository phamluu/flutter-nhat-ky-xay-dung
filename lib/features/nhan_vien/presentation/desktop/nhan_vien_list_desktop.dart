import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/nhan_vien/presentation/desktop/nhan_vien_detail_desktop.dart';
import 'package:nhat_ky_xay_dung/features/nhan_vien/presentation/desktop/nhan_vien_form_desktop.dart';

import '../../../../core/utils/AuthHelper.dart';
import '../../../../core/utils/SyncColor.dart';
import '../../../../core/utils/trang_thai_dong_bo.dart';
import '../../data/models/NhanVien.dart';
import '../../../../services/SyncService.dart';
import '../../data/services/nhan_vien_service.dart';
import '../mobile/ThemSuaNhanVienScreen.dart';
import '../mobile/XemChiTietNhanVienScreen.dart';

class NhanVienListDesktop extends StatefulWidget {
  const NhanVienListDesktop({super.key});

  @override
  State<NhanVienListDesktop> createState() => _NhanVienListDesktopState();
}

class _NhanVienListDesktopState extends State<NhanVienListDesktop> {
  bool isLoggedIn = false;

  final _service = NhanVienService();
  final SyncService syn = SyncService();

  late Future<List<NhanVien>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
    checkLogin();
  }

  void _reload() {
    _future = _service.getAllNhanVien();
  }

  Future<void> checkLogin() async {
    final loggedIn = await AuthHelper.isLoggedIn();

    if (!mounted) return;

    setState(() {
      isLoggedIn = loggedIn;
    });
  }

  Future<void> _openForm({NhanVien? nhanVien}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NhanVienFormDesktop(
          nhanVien: nhanVien,
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() => _reload());
    }
  }

  Future<void> _viewDetail(NhanVien nv) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NhanVienDetailDesktop(
          nhanVien: nv,
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() => _reload());
    }
  }

  Future<void> _deleteNhanVien(NhanVien nv) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: Text(
            "Bạn có chắc muốn xóa nhân viên '${nv.hoTen}'?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Hủy"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Xóa"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _service.deleteNhanVien(nv.id!);

      if (!mounted) return;

      setState(() => _reload());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã xóa nhân viên"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi xóa nhân viên: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _syncNhanVien(NhanVien nv) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Xác nhận đồng bộ"),
          content: Text(
            "Đồng bộ nhân viên '${nv.hoTen}'?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Không"),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Đồng bộ"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await syn.syncOneNhanVien(nv);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã đồng bộ nhân viên"),
          backgroundColor: Colors.green,
        ),
      );

      setState(() => _reload());
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi đồng bộ: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelSyncNhanVien(NhanVien nv) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Xác nhận hủy đồng bộ"),
          content: Text(
            "Hủy đồng bộ nhân viên '${nv.hoTen}'?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Không"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Hủy sync"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await syn.cancelSyncNhanVien(nv);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã hủy đồng bộ"),
          backgroundColor: Colors.orange,
        ),
      );

      setState(() => _reload());
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6f8),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Danh sách nhân viên",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: FutureBuilder<List<NhanVien>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _ErrorView(
              error: snapshot.error.toString(),
              onRetry: () {
                setState(() => _reload());
              },
            );
          }

          final data = snapshot.data ?? [];

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1400,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopBar(data.length),
                    const SizedBox(height: 16),

                    Expanded(
                      child: data.isEmpty
                          ? const _EmptyView()
                          : _buildTable(data),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(int total) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Nhân viên",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Quản lý danh sách nhân viên trong hệ thống",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 19,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                "$total nhân viên",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        FilledButton.icon(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add),
          label: const Text("Thêm nhân viên"),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTable(List<NhanVien> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          child: DataTable(
            headingRowHeight: 54,
            dataRowMinHeight: 70,
            dataRowMaxHeight: 78,
            horizontalMargin: 24,
            columnSpacing: 30,

            headingRowColor: WidgetStateProperty.all(
              const Color(0xfffafafa),
            ),

            columns: const [
              DataColumn(
                label: Text(
                  "STT",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "NHÂN VIÊN",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "EMAIL",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "TRẠNG THÁI",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "THAO TÁC",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],

            rows: List.generate(
              data.length,
                  (index) {
                final nv = data[index];

                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        "${index + 1}",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),

                    DataCell(
                      InkWell(
                        onTap: () => _viewDetail(nv),
                        child: _EmployeeCell(nv: nv),
                      ),
                    ),

                    DataCell(
                      Text(
                        nv.email?.isNotEmpty == true
                            ? nv.email!
                            : "-",
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),

                    DataCell(
                      _SyncStatus(nv: nv),
                    ),

                    DataCell(
                      _ActionButtons(
                        nv: nv,
                        isLoggedIn: isLoggedIn,
                        onDetail: () => _viewDetail(nv),
                        onEdit: () => _openForm(nhanVien: nv),
                        onDelete: () => _deleteNhanVien(nv),
                        onSync: () {
                          if (nv.isSynced ==
                              TrangThaiDongBo.dadongbo.value) {
                            _cancelSyncNhanVien(nv);
                          } else {
                            _syncNhanVien(nv);
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _EmployeeCell extends StatelessWidget {
  final NhanVien nv;

  const _EmployeeCell({
    required this.nv,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Row(
        children: [
          _Avatar(nv: nv),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nv.hoTen ?? "Không tên",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  nv.id?.toString() ?? "-",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final NhanVien nv;

  const _Avatar({
    required this.nv,
  });

  @override
  Widget build(BuildContext context) {
    if (nv.hinhAnh != null && nv.hinhAnh!.isNotEmpty) {
      return CircleAvatar(
        radius: 21,
        backgroundImage: AssetImage(nv.hinhAnh!),
      );
    }

    return CircleAvatar(
      radius: 21,
      backgroundColor: Colors.blue.shade50,
      child: Icon(
        Icons.person,
        color: Colors.blue.shade600,
      ),
    );
  }
}

class _SyncStatus extends StatelessWidget {
  final NhanVien nv;

  const _SyncStatus({
    required this.nv,
  });

  @override
  Widget build(BuildContext context) {
    final isSynced =
        nv.isSynced == TrangThaiDongBo.dadongbo.value;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SyncColor.icon(nv.isSynced),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: isSynced
                ? Colors.green.withOpacity(0.08)
                : Colors.orange.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isSynced ? "Đã đồng bộ" : "Chưa đồng bộ",
            style: TextStyle(
              color: isSynced
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final NhanVien nv;
  final bool isLoggedIn;

  final VoidCallback onDetail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSync;

  const _ActionButtons({
    required this.nv,
    required this.isLoggedIn,
    required this.onDetail,
    required this.onEdit,
    required this.onDelete,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          tooltip: "Xem chi tiết",
          icon: Icons.visibility_outlined,
          color: Colors.blue,
          onPressed: onDetail,
        ),

        const SizedBox(width: 6),

        _ActionButton(
          tooltip: "Chỉnh sửa",
          icon: Icons.edit_outlined,
          color: Colors.indigo,
          onPressed: onEdit,
        ),

        if (isLoggedIn) ...[
          const SizedBox(width: 6),

          _ActionButton(
            tooltip: nv.isSynced ==
                TrangThaiDongBo.dadongbo.value
                ? "Hủy đồng bộ"
                : "Đồng bộ",
            icon: nv.isSynced ==
                TrangThaiDongBo.dadongbo.value
                ? Icons.sync_disabled
                : Icons.sync,
            color: nv.isSynced ==
                TrangThaiDongBo.dadongbo.value
                ? Colors.orange
                : Colors.green,
            onPressed: onSync,
          ),
        ],

        const SizedBox(width: 6),

        _ActionButton(
          tooltip: "Xóa",
          icon: Icons.delete_outline,
          color: Colors.red,
          onPressed: onDelete,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: onPressed,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              icon,
              size: 19,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 70,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            "Chưa có nhân viên nào",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Hãy thêm nhân viên để bắt đầu quản lý.",
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            "Không thể tải danh sách nhân viên",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text("Thử lại"),
          ),
        ],
      ),
    );
  }
}