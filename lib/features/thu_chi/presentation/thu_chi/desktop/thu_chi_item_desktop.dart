import 'package:flutter/material.dart';
import '../../../../../core/utils/currencyFormat.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../../data/models/ThuChi.dart';
import '../widgets/thu_chi_button.dart';
import 'thu_chi_detail_desktop.dart';
import 'thu_chi_form_desktop.dart';

class ThuChiTableDesktop extends StatelessWidget {
  final List<ThuChi> items;
  final VoidCallback onRefresh;

  const ThuChiTableDesktop({
    super.key,
    required this.items,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffe2e8f0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            // ==========================================
            // TABLE HEADER
            // ==========================================
            Container(
              color: const Color(0xfff8fafc),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Row(
                children: [
                  Expanded(
                    flex: 9,
                    child: Text(
                      'LOẠI',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff64748b)),
                    ),
                  ),
                  Expanded(
                    flex: 25,
                    child: Text(
                      'TÊN HÀNG',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff64748b)),
                    ),
                  ),
                  Expanded(
                    flex: 11,
                    child: Text(
                      'NGÀY',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff64748b)),
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: Text(
                      'ĐƠN VỊ TÍNH',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff64748b)),
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: Text(
                      'SỐ LƯỢNG',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff64748b)),
                    ),
                  ),
                  Expanded(
                    flex: 12,
                    child: Text(
                      'ĐƠN GIÁ',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff64748b)),
                    ),
                  ),
                  Expanded(
                    flex: 14,
                    child: Text(
                      'THÀNH TIỀN',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff64748b)),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 9,
                    child: Text(
                      'THAO TÁC',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff64748b)),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xffe2e8f0)),

            // ==========================================
            // TABLE BODY (DANH SÁCH DÒNG)
            // ==========================================
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xfff1f5f9)),
              itemBuilder: (context, index) {
                return ThuChiTableRowDesktop(
                  tc: items[index],
                  onRefresh: onRefresh,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ThuChiTableRowDesktop extends StatefulWidget {
  final ThuChi tc;
  final VoidCallback onRefresh;

  const ThuChiTableRowDesktop({
    super.key,
    required this.tc,
    required this.onRefresh,
  });

  @override
  State<ThuChiTableRowDesktop> createState() => _ThuChiTableRowDesktopState();
}

class _ThuChiTableRowDesktopState extends State<ThuChiTableRowDesktop> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final tc = widget.tc;
    final isThu = tc.loai == 1;

    final Color typeColor = isThu ? const Color(0xff16a34a) : const Color(0xffdc2626);
    final Color typeBackground = isThu ? const Color(0xffecfdf3) : const Color(0xfffef2f2);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _isHovering ? const Color(0xfff8fafc) : Colors.white,
        child: InkWell(
          // onTap: () => _openDetail(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // 1. Badge Loại (flex: 9)
                Expanded(
                  flex: 9,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: typeBackground,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isThu ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                            size: 13,
                            color: typeColor,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            isThu ? 'THU' : 'CHI',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: typeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Tên hàng hóa (flex: 25)
                Expanded(
                  flex: 25,
                  child: Text(
                    tc.tenHangHoa?.isNotEmpty == true ? tc.tenHangHoa! : (tc.ghiChu ?? '---'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff334155),
                    ),
                  ),
                ),

                // 3. Ngày (flex: 11)
                Expanded(
                  flex: 11,
                  child: Text(
                    DateUtilsCore.formatDate(tc.ngay),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff64748b),
                    ),
                  ),
                ),

                // 4. Đơn vị tính (flex: 10)
                Expanded(
                  flex: 10,
                  child: Text(
                    tc.donViTinh ?? '---',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xff475569),
                    ),
                  ),
                ),

                // 5. Số lượng (flex: 10)
                Expanded(
                  flex: 10,
                  child: Text(
                    tc.soLuong.toString() ?? '0',
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff334155),
                    ),
                  ),
                ),

                // 6. Đơn giá (flex: 12)
                Expanded(
                  flex: 12,
                  child: Text(
                    tc.donGia != null ? currencyFormat.format(tc.donGia) : '0',
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xff334155),
                    ),
                  ),
                ),

                // 7. Thành tiền (flex: 14)
                Expanded(
                  flex: 14,
                  child: Text(
                    currencyFormat.format(tc.thanhTien),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: typeColor,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // 8. Thao tác (flex: 9)
                Expanded(
                  flex: 9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(
                        tooltip: 'Sửa khoản thu chi',
                        icon: Icons.edit_outlined,
                        color: const Color(0xff2563eb),
                        background: const Color(0xffeff6ff),
                        onPressed: () => _openThuChiForm(context, tc),
                      ),
                      const SizedBox(width: 4),
                      _buildActionButton(
                        tooltip: 'Xóa khoản thu chi',
                        icon: Icons.delete_outline,
                        color: const Color(0xffdc2626),
                        background: const Color(0xfffef2f2),
                        onPressed: () {
                          deleteThuChi(
                            context,
                            tc.id!,
                            widget.onRefresh,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String tooltip,
    required IconData icon,
    required Color color,
    required Color background,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 300),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onPressed,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
        ),
      ),
    );
  }

  Future<void> _openThuChiForm(BuildContext context, ThuChi tc) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ThuChiFormDesktop(thuChi: tc)),
    );
    if (result == true) {
      widget.onRefresh();
    }
  }

  Future<void> _openDetail(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThuChiDetailDesktop(tc: widget.tc),
      ),
    );
    if (result == true) {
      widget.onRefresh();
    }
  }
}