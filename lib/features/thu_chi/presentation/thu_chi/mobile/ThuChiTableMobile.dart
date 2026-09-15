import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/thu_chi/presentation/thu_chi/mobile/thu_chi_form_mobile.dart';

import '../../../../../core/utils/currencyFormat.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../../data/models/ThuChi.dart';
import '../desktop/thu_chi_detail_desktop.dart';
import '../widgets/thu_chi_button.dart';

/// ===============================================================
/// DANH SÁCH THU CHI - MOBILE
/// ===============================================================

class ThuChiTableMobile extends StatelessWidget {
  final List<ThuChi> items;
  final VoidCallback onRefresh;

  const ThuChiTableMobile({
    super.key,
    required this.items,
    required this.onRefresh,
  });


  // @override
  // Widget build(BuildContext context) {
  //   debugPrint('========== ThuChiTableMobile BUILD ==========');
  //   debugPrint('items.length = ${items.length}');
  //
  //   return Container(
  //     width: double.infinity,
  //     height: 300, // QUAN TRỌNG: ép table có chiều cao
  //     margin: const EdgeInsets.all(10),
  //     padding: const EdgeInsets.all(20),
  //     color: Colors.yellow,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'XX - THU CHI TABLE MOBILE',
  //           style: TextStyle(
  //             fontSize: 24,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.red,
  //           ),
  //         ),
  //         const SizedBox(height: 20),
  //         Text(
  //           'items.length = ${items.length}',
  //           style: const TextStyle(
  //             fontSize: 20,
  //             color: Colors.black,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _buildEmpty(context);
    }

    debugPrint('items.length = ${items.length}');

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        10,
        8,
        10,
        20,
      ),
      child: Column(
        children: List.generate(
          items.length,
              (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ThuChiTableRowMobile(
                tc: items[index],
                onRefresh: onRefresh,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xfff1f5f9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 34,
                color: Color(0xff94a3b8),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Chưa có khoản thu chi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xff334155),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Các khoản thu chi sẽ hiển thị tại đây',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xff94a3b8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================================================
/// CARD TỪNG KHOẢN THU CHI - MOBILE
/// ===============================================================

class ThuChiTableRowMobile extends StatelessWidget {
  final ThuChi tc;
  final VoidCallback onRefresh;

  const ThuChiTableRowMobile({
    super.key,
    required this.tc,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final bool isThu = tc.loai == 1;

    final Color typeColor =
        isThu ? const Color(0xff16a34a) : const Color(0xffdc2626);

    final Color typeBackground =
        isThu ? const Color(0xffecfdf3) : const Color(0xfffef2f2);

    final String tenHangHoa = tc.tenHangHoa?.trim().isNotEmpty == true
        ? tc.tenHangHoa!.trim()
        : (tc.ghiChu?.trim().isNotEmpty == true
            ? tc.ghiChu!.trim()
            : 'Không có tên');

    final String donVi =
        tc.donViTinh?.trim().isNotEmpty == true ? tc.donViTinh!.trim() : '---';

    final String soLuong = tc.soLuong != null ? tc.soLuong.toString() : '0';

    final String donGia =
        tc.donGia != null ? currencyFormat.format(tc.donGia) : '0';

    final String thanhTien = currencyFormat.format(tc.thanhTien);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openDetail(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xffe2e8f0),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
// =====================================================
// HEADER
// =====================================================

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
// THU / CHI
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: typeBackground,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isThu
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          size: 14,
                          color: typeColor,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          isThu ? 'THU' : 'CHI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: typeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
// NGÀY
                  Text(
                    DateUtilsCore.formatDate(tc.ngay),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff64748b)
                    ),
                  ),

// MENU
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    icon: const Icon(
                      Icons.more_vert,
                      size: 21,
                      color: Color(0xff64748b),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _openThuChiForm(context);
                      } else if (value == 'delete') {
                        deleteThuChi(
                          context,
                          tc.id!,
                          onRefresh,
                        );
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 19,
                              color: Color(0xff2563eb),
                            ),
                            SizedBox(width: 8),
                            Text('Sửa'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 19,
                              color: Color(0xffdc2626),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Xóa',
                              style: TextStyle(
                                color: Color(0xffdc2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

// =====================================================
// TÊN HÀNG HÓA
// =====================================================

              Text(
                tenHangHoa,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff1e293b),
                ),
              ),
              const SizedBox(height: 12),

// =====================================================
// THÔNG TIN SỐ LƯỢNG
// =====================================================

              if (tc.soLuong != null || tc.donViTinh != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xfff8fafc),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _infoItem(
                          label: 'Số lượng',
                          value: '$soLuong $donVi',
                          icon: Icons.inventory_2_outlined,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: const Color(0xffe2e8f0),
                      ),
                      Expanded(
                        child: _infoItem(
                          label: 'Đơn giá',
                          value: '$donGia đ',
                          icon: Icons.payments_outlined,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

// =====================================================
// THÀNH TIỀN
// =====================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: typeBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 19,
                      color: typeColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Thành tiền',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: typeColor,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        '$thanhTien đ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

// =====================================================
// GHI CHÚ
// =====================================================

              if (tc.ghiChu?.trim().isNotEmpty == true &&
                  tc.tenHangHoa?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.notes_outlined,
                      size: 16,
                      color: Color(0xff94a3b8),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        tc.ghiChu!.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xff64748b),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

// ===============================================================
// ITEM THÔNG TIN
// ===============================================================

  Widget _infoItem({
    required String label,
    required String value,
    required IconData icon,
    TextAlign textAlign = TextAlign.left,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: textAlign == TextAlign.right
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: textAlign == TextAlign.right
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 14,
                color: const Color(0xff94a3b8),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xff94a3b8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: textAlign,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xff334155),
            ),
          ),
        ],
      ),
    );
  }

// ===============================================================
// MỞ FORM SỬA
// ===============================================================

  Future<void> _openThuChiForm(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThuChiFormMobile(
          thuChi: tc,
        ),
      ),
    );

    if (result == true) {
      onRefresh();
    }
  }

// ===============================================================
// MỞ CHI TIẾT
// ===============================================================

  Future<void> _openDetail(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThuChiDetailDesktop(
          tc: tc,
        ),
      ),
    );

    if (result == true) {
      onRefresh();
    }
  }
}
