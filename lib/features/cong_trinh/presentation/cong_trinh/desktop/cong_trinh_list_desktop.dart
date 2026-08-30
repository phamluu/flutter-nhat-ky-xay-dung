import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';
import '../../../../../core/utils/SyncColor.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../../data/models/CongTrinh.dart';
import '../../../data/respositories/CongTrinhReponsitory.dart';
import 'cong_trinh_detail_desktop.dart';
import 'cong_trinh_form_desktop.dart';

class CongTrinhListDesktop extends StatefulWidget {
  const CongTrinhListDesktop({super.key});

  @override
  State<CongTrinhListDesktop> createState() =>
      _CongTrinhListDesktopState();
}

class _CongTrinhListDesktopState extends State<CongTrinhListDesktop> {
  final _service = CongtrinhReponsitory();

  late Future<List<CongTrinh>> _futureCongTrinh;

  final TextEditingController _searchController =
  TextEditingController();

  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _futureCongTrinh = _service.getCongTrinhWithTienDo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6f8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 20),

              _buildToolbar(),

              const SizedBox(height: 16),

              Expanded(
                child: FutureBuilder<List<CongTrinh>>(
                  future: _futureCongTrinh,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child:
                        CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return _buildError(
                        snapshot.error.toString(),
                      );
                    }

                    final data =
                    _filterData(
                      snapshot.data ?? [],
                    );

                    if (data.isEmpty) {
                      return _buildEmpty();
                    }

                    return _buildTable(data);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openThemCongTrinh() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CongTrinhFormDesktop(),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _openSuaCongTrinh(
      CongTrinh congTrinh,
      ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CongTrinhFormDesktop(
          congTrinh: congTrinh,
        ),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _openChiTiet(
      CongTrinh congTrinh,
      ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CongTrinhDetailDesktop(
          congTrinh: congTrinh,
        ),
      ),
    );
  }

  Future<void> _deleteCongTrinh(
      CongTrinh congTrinh,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text(
            'Bạn có chắc muốn xóa công trình '
                '"${congTrinh.ten}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
              child: const Text('Hủy'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(ctx, true);
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _service.deleteCongTrinh(
        congTrinh.id!,
      );

      if (!mounted) return;
showSuccessToast(context, 'Xóa công trình thành công');

      _loadData();
    } catch (e) {
      if (!mounted) return;
showErrorToast(context, e, 'Không thể xóa công trình');
    }
  }

  List<CongTrinh> _filterData(List<CongTrinh> data ) {
    if (_searchText.trim().isEmpty) {
      return data;
    }
    final keyword = _searchText.trim().toLowerCase();
    return data.where((item) {
      final ten = item.ten.toLowerCase();
      final diaChi = item.diaChi?.toLowerCase() ?? '';
      return ten.contains(keyword) || diaChi.contains(keyword);
    }).toList();
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Công trình',
                style: TextStyle( fontSize: 26, fontWeight: FontWeight.bold, ),
              ),
              SizedBox(height: 4),
              Text(
                'Quản lý danh sách các công trình xây dựng',
                style: TextStyle( color: Colors.grey, fontSize: 14, ),
              ),
            ],
          ),
        ),

        FilledButton.icon(
          onPressed: _openThemCongTrinh,
          icon: const Icon(Icons.add),
          label: const Text( 'Thêm công trình',),
        ),
      ],
    );
  }

  // =========================================================
  // TOOLBAR
  // =========================================================

  Widget _buildToolbar() {
    return Row(
      children: [
        SizedBox(
          width: 360,
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Tìm kiếm công trình...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchText.isNotEmpty
                  ? IconButton(
                icon: const Icon( Icons.clear, ),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchText = '';
                  });
                },
              )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: _loadData,
          icon: const Icon( Icons.refresh,),
          label: const Text('Làm mới'),
        ),
      ],
    );
  }

  // =========================================================
  // TABLE
  // =========================================================

  Widget _buildTable(List<CongTrinh> data, ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(12),
        child: Column(
          children: [
            _buildTableHeader(),

            Expanded(
              child: ListView.separated(
                itemCount: data.length,
                separatorBuilder:
                    (_, __) => Divider(
                  height: 1,
                  color:
                  Colors.grey.shade200,
                ),
                itemBuilder:
                    (context, index) {
                  return _buildTableRow(
                    data[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // TABLE HEADER
  // =========================================================

  Widget _buildTableHeader() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          const SizedBox(
            width: 70,
            child: Text(
              'Ảnh',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Expanded(
            flex: 3,
            child: Text(
              'Công trình',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Expanded(
            flex: 3,
            child: Text(
              'Ngày',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Expanded(
            flex: 3,
            child: Text(
              'Địa chỉ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Expanded(
            flex: 2,
            child: Text(
              'Tiến độ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(
            width: 90,
            child: Text(
              'Đồng bộ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(
            width: 150,
            child: Text(
              'Thao tác',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TABLE ROW
  // =========================================================

  Widget _buildTableRow( CongTrinh ct,) {
    final progress = ((ct.tienDo ?? 0) / 100).clamp(0.0, 1.0);
    return InkWell(
      onDoubleTap: () { _openChiTiet(ct); },
      child: Container(
        constraints: const BoxConstraints( minHeight: 82, ),
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        child: Row(
          children: [
            // ẢNH
            SizedBox(
              width: 70,
              child: _buildThumbnail(ct),
            ),
            const SizedBox(width: 12),
            // TÊN
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ct.ten,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mã: ${ct.id ?? '-'}',
                    style: const TextStyle( color: Colors.grey, fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Ngày
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Text(
                    DateUtilsCore.formatDate(ct.ngayBatDau ?? '-'),
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                  Text( ' - ',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle( color: Colors.black87,),
                  ),
                  Text(
                    DateUtilsCore.formatDate(ct.ngayKetThuc ?? '-'),
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            // ĐỊA CHỈ
            Expanded(
              flex: 3,
              child: Text(
                ct.diaChi ?? '-',
                maxLines: 2,
                overflow:
                TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black87,
                ),
              ),
            ),

            // TIẾN ĐỘ
            Expanded(
              flex: 2,
              child: Padding(
                padding:
                const EdgeInsets.only(
                  right: 20,
                ),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child:
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            borderRadius:
                            BorderRadius
                                .circular(
                              10,
                            ),
                            backgroundColor:
                            Colors
                                .grey
                                .shade200,
                            color:
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          '${(ct.tienDo ?? 0).toStringAsFixed(0)}%',
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ĐỒNG BỘ
            SizedBox(
              width: 90,
              child: Row(
                children: [
                  SyncColor.icon(
                    ct.isSynced,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    ct.isSynced != null
                        ? 'Đã đồng bộ'
                        : 'Chưa đồng bộ',
                    style: TextStyle(
                      fontSize: 12,
                      color: ct.isSynced != null
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            // THAO TÁC
            SizedBox(
              width: 150,
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Xem chi tiết',
                    onPressed: () {
                      _openChiTiet(ct);
                    },
                    icon: const Icon(
                      Icons.visibility_outlined,
                    ),
                  ),

                  IconButton(
                    tooltip: 'Sửa',
                    onPressed: () {
                      _openSuaCongTrinh(ct);
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                  ),

                  IconButton(
                    tooltip: 'Xóa',
                    onPressed: () {
                      _deleteCongTrinh(ct);
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
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

  // =========================================================
  // THUMBNAIL
  // =========================================================

  Widget _buildThumbnail(
      CongTrinh ct,
      ) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(8),
        color: Colors.grey.shade100,
      ),
      clipBehavior: Clip.antiAlias,
      child: ct.hinhAnh != null
          ? Image.file(
        File(ct.hinhAnh!),
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
    );
  }

  // =========================================================
  // EMPTY
  // =========================================================

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          const Text(
            'Chưa có công trình nào',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
              FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Hãy thêm công trình đầu tiên',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ERROR
  // =========================================================

  Widget _buildError(
      String error,
      ) {
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          const Text(
            'Không thể tải danh sách công trình',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}