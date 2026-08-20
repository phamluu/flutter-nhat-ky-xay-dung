import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/ThuChi.dart';
import 'ThuChiItem.dart';

class CongTySection extends StatefulWidget {
  final ThuChiCongTyViewModel congTyVM;
  final NumberFormat currencyFormat;
  final VoidCallback onRefresh;

  const CongTySection({
    super.key,
    required this.congTyVM,
    required this.currencyFormat,
    required this.onRefresh,
  });

  @override
  State<CongTySection> createState() => _CongTySectionState();
}

class _CongTySectionState extends State<CongTySection> {
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
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Thu chi công ty",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              widget.currencyFormat.format(widget.congTyVM.conLai),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          // --- Mỗi Danh mục: header + list các ThuChi ---
          ...widget.congTyVM.thuChiDanhMucs.expand((dmVM) sync* {
            // header danh mục
            yield Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade400,
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

            // các item thuộc danh mục
            for (var tc in dmVM.thuchis!) {
              yield Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: ThuChiItem(tc: tc, onRefresh: widget.onRefresh),
              );
            }
          }).toList(),

          // --- Nhóm "Khác" (không có danh mục) ---
          if (widget.congTyVM.thuChiKhacs.thuchis!.isNotEmpty) ...[
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
                        .format(widget.congTyVM.thuChiKhacs.conLai),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            ...?widget.congTyVM.thuChiKhacs.thuchis
                ?.map((tc) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ThuChiItem(tc: tc, onRefresh: widget.onRefresh),
            ))
                .toList(),
          ],
        ],
      ),
    );
  }
}
