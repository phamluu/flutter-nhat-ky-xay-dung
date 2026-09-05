import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/utils/currencyFormat.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/models/phien_chot_cong.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/cham_cong_luong_repo.dart';

class DotChotCongDetailDesktop extends StatefulWidget {
  final PhienChotCong phienChot;
  const DotChotCongDetailDesktop({
    super.key,
    required this.phienChot,
  });

  @override
  State<DotChotCongDetailDesktop> createState() =>
      _DotChotCongDetailDesktopState();
}

class _DotChotCongDetailDesktopState extends State<DotChotCongDetailDesktop> {
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';
  late final ChamCongLuongRepo _repo;
  late List<ChamCongLuongNhanVien> _model = [];

  // Set chứa danh sách ID nhân viên công trình đang được tích chọn
  final Set<int> _selectedIds = {};
  final List<ChamCongLuongNhanVien> _selectedNhanVien = [];
  @override
  void initState() {
    super.initState();
    _repo = ChamCongLuongRepo();
    _load();
  }

  Future<void> _load() async {
    final rs = await _repo.chamCongNhanVienPhienChot(widget.phienChot.id);
    setState(() {
      _model = rs;
      _selectedNhanVien.clear();
      _selectedNhanVien.addAll(
        _model
            .map((e) => e.idNhanVienCongTrinh)
          .whereType<ChamCongLuongNhanVien>(),
      );
      // Mặc định chọn tất cả khi mới load danh sách
      _selectedIds.clear();
      _selectedIds.addAll(
        _model
            .map((e) => e.idNhanVienCongTrinh)
            .whereType<int>(),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Danh sách đã qua lọc tìm kiếm
  List<ChamCongLuongNhanVien> get _filteredModel {
    if (_searchKeyword.isEmpty) return _model;
    return _model.where((item) {
      final name = item.hoTen?.toLowerCase() ?? '';
      return name.contains(_searchKeyword);
    }).toList();
  }

  // Kiểm tra trạng thái Checkbox "Chọn tất cả"
  bool get _isAllSelected {
    final filteredList = _filteredModel;
    if (filteredList.isEmpty) return false;
    return filteredList.every((e) => _selectedIds.contains(e.idNhanVienCongTrinh));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          'Chi tiết đợt chốt công #${widget.phienChot.maDot ?? widget.phienChot.id}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0.5,
        actions: [
          // Nút Hủy chốt lương (Dành cho các mục đã chọn)
          OutlinedButton.icon(
            onPressed: _selectedIds.isEmpty
                ? null
                : () => _xacNhanHuyChotLuong(context),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: Text('Hủy chốt lương (${_selectedIds.length})'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(width: 8),
          // Nút Chốt lương đợt này
          ElevatedButton.icon(
            onPressed: _selectedIds.isEmpty
                ? null
                : () => _xacNhanChotLuong(context),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: Text('Chốt lương (${_selectedIds.length})'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(width: 16),
          // Nút Chi lương hàng loạt
          ElevatedButton.icon(
            onPressed: _selectedIds.isEmpty
                ? null
                : () => _xacNhanChiLuongHangLoat(context),
            icon: const Icon(Icons.payments_outlined, size: 18),
            label: Text('Chi lương (${_selectedIds.length})'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thẻ thông tin tổng quan
            _buildSummaryCards(),
            const SizedBox(height: 16),

            // 2. Thanh tìm kiếm & bộ lọc
            _buildFilterBar(),
            const SizedBox(height: 12),

            // 3. Bảng danh sách chi tiết nhân viên
            Expanded(
              child: _buildEmployeeTable(),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. THẺ TỔNG QUAN (Cập nhật theo danh sách tích chọn) ---
  Widget _buildSummaryCards() {
    // Tính toán số liệu dựa trên các mục ĐƯỢC TÍCH CHỌN
    final selectedList = _model.where((e) => _selectedIds.contains(e.idNhanVienCongTrinh));
    final double tongSoCong = selectedList.fold(0.0, (sum, nv) => sum + nv.soCong);
    final double tongTienLuong = selectedList.fold(0.0, (sum, nv) => sum + nv.tongLuong);

    return Row(
      children: [
        _buildInfoCard(
          title: 'ĐỢT CHỐT CÔNG',
          value: 'Đợt ${widget.phienChot.maDot ?? widget.phienChot.id}',
          subText: 'Đến ngày: ${widget.phienChot.denNgayStr ?? widget.phienChot.ngayChot ?? "N/A"}',
          icon: Icons.date_range,
          color: Colors.blue,
        ),
        const SizedBox(width: 12),
        _buildInfoCard(
          title: 'ĐÃ CHỌN',
          value: '${_selectedIds.length} / ${_model.length} người',
          subText: 'Nhân viên trong danh sách',
          icon: Icons.people_outline,
          color: Colors.orange,
        ),
        const SizedBox(width: 12),
        _buildInfoCard(
          title: 'TỔNG CÔNG ĐÃ CHỌN',
          value: '$tongSoCong công',
          subText: 'Tổng số ngày công',
          icon: Icons.access_time_filled,
          color: Colors.teal,
        ),
        const SizedBox(width: 12),
        _buildInfoCard(
          title: 'TỔNG LƯƠNG ĐÃ CHỌN',
          value: currencyFormat.format(tongTienLuong),
          subText: 'Sẵn sàng chốt/chi lương',
          icon: Icons.monetization_on_outlined,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required String subText,
    required IconData icon,
    required MaterialColor color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color.shade700, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subText,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. THANH BỘ LỌC VÀ TÌM KIẾM ---
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 300,
            height: 38,
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchKeyword = val.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm theo tên...',
                hintStyle: const TextStyle(fontSize: 13),
                prefixIcon: const Icon(Icons.search, size: 18),
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Đã chọn ${_selectedIds.length} nhân viên',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
          ),
        ],
      ),
    );
  }

  // --- 3. BẢNG DỮ LIỆU NHÂN VIÊN ---
  Widget _buildEmployeeTable() {
    final displayList = _filteredModel;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    headingRowColor:
                    WidgetStateProperty.all(Colors.grey.shade50),
                    headingRowHeight: 45,
                    dataRowMinHeight: 48,
                    dataRowMaxHeight: 52,

                    columnSpacing: 24,
                    horizontalMargin: 16,

                    columns: const [
                      DataColumn(
                        label: Text(
                          'STT',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'HỌ VÀ TÊN',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'CHỨC VỤ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'SỐ CÔNG',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'TỔNG LƯƠNG',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'ĐÃ ỨNG',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'TRỪ ỨNG',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'THỰC NHẬN',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'TRẠNG THÁI',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'THAO TÁC',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],

                    rows: displayList.asMap().entries.map((e) {
                      final index = e.key;
                      final item = e.value;
                      final idNv = item.idNhanVienCongTrinh;

                      final isSelected =
                      _selectedIds.contains(idNv);

                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (bool? selected) {
                          if (idNv == null) return;
                          setState(() {
                            if (selected == true) {
                              _selectedIds.add(idNv);
                            } else {
                              _selectedIds.remove(idNv);
                            }
                          });
                        },
                        cells: [
                          DataCell(
                            Text('${index + 1}'),
                          ),

                          DataCell(
                            Text(
                              item.hoTen ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          DataCell(
                            Text(item.chucVu ?? '-'),
                          ),

                          DataCell(
                            Text('${item.soCong} công'),
                          ),

                          DataCell(
                            Text(
                              currencyFormat.format(item.tongLuong),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ),

                          DataCell(
                            Text('${currencyFormat.format(item.tongUng ?? 0)}'),
                          ),

                          DataCell(
                            Text('${currencyFormat.format(item.tongUngDaTru ?? 0)}'),
                          ),

                          DataCell(
                            Text('${currencyFormat.format(item.thucNhan ?? 0)}'),
                          ),

                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius:
                                BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Đã chốt công',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),

                          DataCell(
                            IconButton(
                              icon: const Icon(
                                Icons.payment,
                                color: Colors.green,
                                size: 20,
                              ),
                              tooltip: 'Chi lương riêng',
                              onPressed: () {
                                // TODO
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- DIALOG XÁC NHẬN CHỐT LƯƠNG ---
  void _xacNhanChotLuong(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận chốt lương'),
        content: Text(
          'Bạn có chắc chắn muốn chốt lương cho ${_selectedIds.length} nhân viên đã chọn không?\n'
              'Sau khi chốt, dữ liệu sẽ được chuyển sang danh sách kỳ lương.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try{
                await _repo.chotLuongTheoDanhSach(danhSachDuocChon: _selectedNhanVien, idPhienChot: widget.phienChot.id);
                showSuccessToast(context, "Chốt lương thành công");
                _load();
                Navigator.pop(ctx);
              }catch(e){
                showErrorToast(context, e, "Không thể chốt");
              }
            },
            child: const Text('Đồng ý chốt'),
          ),
        ],
      ),
    );
  }

  // --- DIALOG HỦY CHỐT LƯƠNG ---
  void _xacNhanHuyChotLuong(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận hủy chốt lương'),
        content: Text(
          'Bạn có chắc muốn HỦY CHỐT LƯƠNG cho ${_selectedIds.length} nhân viên đã chọn?\n'
              'Dữ liệu lương sẽ được mở khóa để có thể điều chỉnh lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bỏ qua'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Gọi Repo xử lý hủy chốt lương cho danh sách _selectedIds.toList()
            },
            child: const Text('Đồng ý hủy chốt'),
          ),
        ],
      ),
    );
  }

  // --- DIALOG CHI LƯƠNG HÀNG LOẠT ---
  void _xacNhanChiLuongHangLoat(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận chi lương hàng loạt'),
        content: Text(
          'Xác nhận đã thanh toán/chi lương cho ${_selectedIds.length} nhân viên đã chọn?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Gọi Repo xử lý cập nhật trạng thái đã chi lương
            },
            child: const Text('Xác nhận chi'),
          ),
        ],
      ),
    );
  }
}