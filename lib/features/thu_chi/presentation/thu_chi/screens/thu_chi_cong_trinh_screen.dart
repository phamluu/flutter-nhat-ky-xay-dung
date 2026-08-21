import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhat_ky_xay_dung/core/utils/currencyFormat.dart';

import '../../../data/models/ThuChi.dart';
import '../../../data/services/thu_chi_service.dart';
import '../widgets/ThuChiItem.dart';
import 'them_thu_chi_screen.dart';

class ThuChiCongTrinhScreen extends StatefulWidget {
  final int? idCongTrinh;
  final String? tenCongTrinh;
  const ThuChiCongTrinhScreen({super.key, this.idCongTrinh, this.tenCongTrinh});

  @override
  State<ThuChiCongTrinhScreen> createState() => _ThuChiCongTrinhScreenState();
}

class _ThuChiCongTrinhScreenState extends State<ThuChiCongTrinhScreen> {
  int? _selectedCongTrinhId;
  final _thuChiService = ThuChiService();
  late Future<ThuChiCongTrinhViewModel> _futureThuChi;
  final _currencyFormat =
  NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _selectedCongTrinhId = widget.idCongTrinh;
    _load();
  }

  void _load() {
    _futureThuChi = _thuChiService.loadThuChiCongTrinh(_selectedCongTrinhId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Quản lý thu chi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_selectedCongTrinhId != null)
              Text(
                widget.tenCongTrinh ?? "",
                style: const TextStyle(fontSize: 13, color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
      body: FutureBuilder<ThuChiCongTrinhViewModel>(
        future: _futureThuChi,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final vm = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // --- Card Tổng quan ---
              Card(
                color: Colors.blue.shade50,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.arrow_downward, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Tổng thu: ${currencyFormat.format(vm.tongThu)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.arrow_upward, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'Tổng chi: ${currencyFormat.format(vm.tongChi)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),
                      Row(
                        children: [
                          const Icon(Icons.account_balance_wallet,
                              color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Còn lại: ${currencyFormat.format(vm.conLai)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: vm.conLai >= 0 ? Colors.blue : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // --- Các nhóm danh mục ---
              ...vm.thuChiDanhMucs.expand((dmVM) sync* {
                yield Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dmVM.danhMucThuChi!.ten,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      Text(
                        currencyFormat.format(dmVM.conLai),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                );

                for (var tc in dmVM.thuchis!) {
                  yield Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: ThuChiItem(tc: tc, onRefresh: _load),
                  );
                }
              }).toList(),

              // --- Nhóm "Khác" ---
              if (vm.thuChiKhacs.thuchis!.isNotEmpty) ...[
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Khác",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      Text(
                        currencyFormat.format(vm.thuChiKhacs.conLai),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                ...?vm.thuChiKhacs.thuchis?.map(
                      (tc) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: ThuChiItem(tc: tc, onRefresh: _load),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) =>  ThemThuChiScreen(idCongTrinh:_selectedCongTrinhId)),
          );
          if (result == true) {
            setState(_load); // refresh danh sách khi thêm mới
          }
        },
      ),
    );
  }


}
