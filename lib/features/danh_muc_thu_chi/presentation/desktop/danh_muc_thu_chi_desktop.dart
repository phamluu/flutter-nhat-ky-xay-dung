import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nhat_ky_xay_dung/features/danh_muc_thu_chi/presentation/desktop/danh_muc_thu_chi_form_desktop.dart';

import '../../../../data/models/DanhMucThuChi.dart';
import '../../../../services/danh_muc_thu_chi_service.dart';
import '../../screens/them_danh_muc_thu_chi_screen.dart';
import '../../widgets/DanhMucActionButton.dart';
import '../../widgets/DeleteDanhMucButton.dart';

class DanhMucThuChiDesktop extends StatefulWidget {
  const DanhMucThuChiDesktop({super.key});

  @override
  State<DanhMucThuChiDesktop> createState() => _DanhMucThuChiDesktopState();
}

class _DanhMucThuChiDesktopState extends State<DanhMucThuChiDesktop> {
  final _service = DanhMucThuChiService();
  late Future<List<DanhMucThuChi>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _service.getAll();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20,),
                Expanded(
                  child: FutureBuilder<List<DanhMucThuChi>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Không thể tải danh mục",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _load();
                                  });
                                },
                                child: const Text("Thử lại"),
                              ),
                            ],
                          ),
                        );
                      }

                      final list = snapshot.data ?? [];
                      return _buildTable(list);
                    },
                  ),
                )
              ],
            ),
          ),

        )


    );
  }
  Widget _buildTable(List<DanhMucThuChi> list) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: list.isEmpty
          ? const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category_outlined,
              size: 56,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text(
              "Chưa có danh mục",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : LayoutBuilder(
        builder: (context, constraints) {
          return Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    // Không cho bảng nhỏ hơn chiều rộng màn hình
                    minWidth: constraints.maxWidth,
                  ),
                  child: DataTable(
                    headingRowHeight: 50,
                    dataRowMinHeight: 64,
                    dataRowMaxHeight: 72,

                    columnSpacing: 50,
                    horizontalMargin: 20,

                    headingRowColor:
                    WidgetStateProperty.all(
                      Colors.grey.shade50,
                    ),

                    columns: const [
                      DataColumn(
                        label: SizedBox(
                          width: 60,
                          child: Text(
                            "STT",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 350,
                          child: Text(
                            "Tên danh mục",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 220,
                          child: Text(
                            "Thao tác",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],

                    rows: List.generate(
                      list.length,
                          (index) {
                        final dm = list[index];

                        return DataRow(
                          cells: [
                            // STT
                            DataCell(
                              SizedBox(
                                width: 60,
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),

                            // Tên danh mục
                            DataCell(
                              SizedBox(
                                width: 350,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.category_outlined,
                                        color: Colors.blue.shade600,
                                        size: 18,
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Text(
                                        dm.ten,
                                        overflow:
                                        TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight:
                                          FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Thao tác
                            DataCell(
                              SizedBox(
                                width: 220,
                                child: Row(
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final result =
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                DanhMucThuChiFormDeskTop(
                                                  danhMuc: dm,
                                                ),
                                          ),
                                        );

                                        if (result == true &&
                                            mounted) {
                                          _load();
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.edit,
                                        size: 17,
                                      ),
                                      label: const Text("Sửa"),
                                      style:
                                      OutlinedButton.styleFrom(
                                        foregroundColor:
                                        Colors.blue,
                                        side: BorderSide(
                                          color:
                                          Colors.blue.shade200,
                                        ),
                                        shape:
                                        RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    OutlinedButton.icon(
                                      onPressed: () {
                                        deleteDanhMuc(
                                          context,
                                          dm.id!,
                                              () {
                                            _load();
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 17,
                                      ),
                                      label: const Text("Xóa"),
                                      style:
                                      OutlinedButton.styleFrom(
                                        foregroundColor:
                                        Colors.red,
                                        side: BorderSide(
                                          color:
                                          Colors.red.shade200,
                                        ),
                                        shape:
                                        RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildHeader(){
    return // Header
      Row(
        children: [
          const Icon(
            Icons.category_outlined,
            size: 28,
            color: Colors.blue,
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  "Danh mục thu chi",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Quản lý các danh mục thu nhập và chi tiêu",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const DanhMucThuChiFormDeskTop(),
                ),
              );

              if (result == true && mounted) {
                setState(() {
                  _load();
                });
              }
            },
            icon: const Icon(Icons.add),
            label: const Text("Thêm danh mục"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      );
  }
}
