import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/ThuChi.dart';
import 'ThuChiItem.dart';

class CongTrinhSection extends StatefulWidget {
  final ThuChiCongTrinhViewModel congTrinhVM;
  final NumberFormat currencyFormat;
  final VoidCallback onRefresh;

  const CongTrinhSection({
    super.key,
    required this.congTrinhVM,
    required this.currencyFormat,
    required this.onRefresh,
  });

  @override
  State<CongTrinhSection> createState() => _CongTrinhSectionState();
}

class _CongTrinhSectionState extends State<CongTrinhSection> {
  bool _isExpanded = false;


  @override
  Widget build(BuildContext context) {

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (v) => setState(() => _isExpanded = v),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.congTrinhVM.congTrinh.ten,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              widget.currencyFormat.format(widget.congTrinhVM.conLai),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          // --- Mỗi Danh mục: header + list ThuChi ---
          ...widget.congTrinhVM.thuChiDanhMucs.expand((dmVM) sync* {
            yield Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.shade400,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dmVM.danhMucThuChi!.ten,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(
                    widget.currencyFormat.format(dmVM.conLai),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );

            for (var tc in dmVM.thuchis!) {
              yield Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: ThuChiItem(tc: tc, onRefresh: widget.onRefresh),
              );
            }
          }).toList(),

          // --- Nhóm "Khác" ---
          if (widget.congTrinhVM.thuChiKhacs.thuchis!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Khác",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(
                    widget.currencyFormat
                        .format(widget.congTrinhVM.thuChiKhacs.conLai),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            ...?widget.congTrinhVM.thuChiKhacs.thuchis?.map(
                  (tc) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: ThuChiItem(tc: tc, onRefresh: widget.onRefresh),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
