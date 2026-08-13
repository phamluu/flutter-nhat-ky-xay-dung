import 'package:flutter/material.dart';

import '../../widgets/chotCongBtn.dart';

class FilterChamCongDesktop extends StatelessWidget {
  final int selectedMonth;
  final int selectedYear;
  final bool daKhoa;
  final bool daChotLuong;

  final Function(int) onMonthChanged;
  final Function(int) onYearChanged;
  final VoidCallback onChotCong;

  const FilterChamCongDesktop({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.daKhoa,
    required this.daChotLuong,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.onChotCong,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // =====================================================
        // THÁNG
        // =====================================================

        SizedBox(
          width: 150,
          child: DropdownButtonFormField<int>(
            value: selectedMonth,

            decoration: InputDecoration(
              labelText: "Tháng",
              prefixIcon: const Icon(
                Icons.calendar_month_outlined,
                size: 18,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,

              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),

              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(9),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),

              enabledBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(9),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),

              focusedBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(9),
                borderSide: BorderSide(
                  color: Colors.blue.shade500,
                  width: 1.5,
                ),
              ),
            ),

            items: List.generate(
              12,
                  (i) {
                final m = i + 1;

                return DropdownMenuItem<int>(
                  value: m,
                  child: Text(
                    "Tháng $m",
                    style:
                    const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                );
              },
            ),

            onChanged: (value) {
              if (value != null) {
                onMonthChanged(value);
              }
            },
          ),
        ),

        const SizedBox(width: 10),

        // =====================================================
        // NĂM
        // =====================================================

        SizedBox(
          width: 130,
          child: DropdownButtonFormField<int>(
            value: selectedYear,

            decoration: InputDecoration(
              labelText: "Năm",
              prefixIcon: const Icon(
                Icons.date_range_outlined,
                size: 18,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,

              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),

              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(9),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),

              enabledBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(9),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),

              focusedBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(9),
                borderSide: BorderSide(
                  color: Colors.blue.shade500,
                  width: 1.5,
                ),
              ),
            ),

            items: List.generate(
              5,
                  (i) {
                final y =
                    DateTime.now().year - 2 + i;

                return DropdownMenuItem<int>(
                  value: y,
                  child: Text(
                    "$y",
                    style:
                    const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                );
              },
            ),

            onChanged: (value) {
              if (value != null) {
                onYearChanged(value);
              }
            },
          ),
        ),

        const Spacer(),

        // =====================================================
        // TRẠNG THÁI
        // =====================================================

        _buildStatus(),

        const SizedBox(width: 12),

        // =====================================================
        // CHỐT / KHÓA CÔNG
        // =====================================================

        ChotCongButton(
          daKhoa: daKhoa,
          daChotLuong: daChotLuong,
          onPressed: onChotCong,
        ),
      ],
    );
  }

  // ===========================================================
  // STATUS
  // ===========================================================

  Widget _buildStatus() {
    final Color color;

    final String text;

    final IconData icon;

    if (daChotLuong) {
      color = Colors.green;
      text = "Đã chốt lương";
      icon = Icons.check_circle_outline;
    } else if (daKhoa) {
      color = Colors.blue;
      text = "Đã khóa công";
      icon = Icons.lock_outline;
    } else {
      color = Colors.orange;
      text = "Chưa khóa công";
      icon = Icons.lock_open_outlined;
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius:
        BorderRadius.circular(9),
        border: Border.all(
          color: color.withOpacity(.18),
        ),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color: color,
          ),

          const SizedBox(width: 7),

          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}