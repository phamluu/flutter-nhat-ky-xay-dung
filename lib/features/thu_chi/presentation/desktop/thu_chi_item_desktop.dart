import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/thu_chi/presentation/desktop/thu_chi_detail_desktop.dart';
import 'package:nhat_ky_xay_dung/features/thu_chi/presentation/desktop/thu_chi_form_desktop.dart';
import '../../../../core/utils/currencyFormat.dart';
import '../../../../data/models/ThuChi.dart';
import '../../widgets/thu_chi_button.dart';


class ThuChiItemDesktop extends StatefulWidget {
  final ThuChi tc;
  final VoidCallback onRefresh;

  const ThuChiItemDesktop({
    super.key,
    required this.tc,
    required this.onRefresh,
  });

  @override
  State<ThuChiItemDesktop> createState() => _ThuChiItemDesktopState();
}

class _ThuChiItemDesktopState extends State<ThuChiItemDesktop> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final tc = widget.tc;
    final isThu = tc.loai == 1;

    final Color typeColor = isThu
        ? const Color(0xff16a34a)
        : const Color(0xffdc2626);

    final Color typeBackground = isThu
        ? const Color(0xffecfdf3)
        : const Color(0xfffef2f2);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _isHovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovering = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: _isHovering
              ? const Color(0xfff8fafc)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _isHovering
                ? const Color(0xffdbe3ee)
                : const Color(0xffedf0f3),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _openDetail(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            child: Row(
              children: [
                // ==================================================
                // LOẠI THU / CHI
                // ==================================================

                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: typeBackground,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    isThu
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    size: 19,
                    color: typeColor,
                  ),
                ),

                const SizedBox(width: 12),

                // ==================================================
                // NỘI DUNG
                // ==================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: typeBackground,
                              borderRadius:
                              BorderRadius.circular(5),
                            ),
                            child: Text(
                              isThu ? 'THU' : 'CHI',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: typeColor,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              tc.ghiChu?.isNotEmpty == true
                                  ? tc.ghiChu!
                                  : 'Không có ghi chú',
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff334155),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Nhấn để xem chi tiết',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // ==================================================
                // SỐ TIỀN
                // ==================================================

                SizedBox(
                  width: 150,
                  child: Text(
                    currencyFormat.format(tc.soTien),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: typeColor,
                    ),
                  ),
                ),

                const SizedBox(width: 18),

                // ==================================================
                // ACTION DESKTOP
                // ==================================================

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(
                      tooltip: 'Sửa khoản thu chi',
                      icon: Icons.edit_outlined,
                      color: const Color(0xff2563eb),
                      background:
                      const Color(0xffeff6ff),
                      onPressed: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ThuChiFormDesktop(thuChi: tc)),
                        );
                        // openThuChiForm(
                        //   context,
                        //   tc,
                        //   widget.onRefresh,
                        // );
                      },
                    ),

                    const SizedBox(width: 6),

                    _buildActionButton(
                      tooltip: 'Xóa khoản thu chi',
                      icon: Icons.delete_outline,
                      color: const Color(0xffdc2626),
                      background:
                      const Color(0xfffef2f2),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget _buildActionButton({
    required String tooltip,
    required IconData icon,
    required Color color,
    required Color background,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      waitDuration:
      const Duration(milliseconds: 400),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: onPressed,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              icon,
              size: 17,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DETAIL
  // ============================================================

  Future<void> _openDetail(
      BuildContext context,
      ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThuChiDetailDesktop(
          tc: widget.tc,
        ),
      ),
    );

    if (result == true) {
      widget.onRefresh();
    }
  }
}