import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/currencyFormat.dart';
import '../../../data/models/ThuChi.dart';
import '../../../data/services/thu_chi_service.dart';
import '../widgets/CongTrinhSection.dart';
import '../widgets/CongTySection.dart';
import 'them_thu_chi_screen.dart';

class ThuChiScreen extends StatefulWidget {
  final int? idCongTrinh;
  final String? tenCongTrinh;
  const ThuChiScreen({super.key, this.idCongTrinh, this.tenCongTrinh});

  @override
  State<ThuChiScreen> createState() => _ThuChiScreenState();
}

class _ThuChiScreenState extends State<ThuChiScreen> {
  int? _selectedCongTrinhId;
  final _thuChiService = ThuChiService();
  late Future<ThuChiViewModel> _futureThuChi;
  final _currencyFormat =
  NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _selectedCongTrinhId = widget.idCongTrinh;
    _load();
  }

  void _load() {
    _futureThuChi = _thuChiService.loadThuChiViewModel(_selectedCongTrinhId);
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
                style: const TextStyle(fontSize: 13, color: Colors.black54),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
      body: FutureBuilder<ThuChiViewModel>(
        future: _futureThuChi,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final vm = snapshot.data!;

          return ListView(
            children: [
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tổng thu: ${currencyFormat.format(vm.tongThu)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tổng chi: ${currencyFormat.format(vm.tongChi)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                        const Divider(),
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
                  ),
                ),
              ),

              if (_selectedCongTrinhId == null)
              CongTySection(
                congTyVM: vm.thuChiCongTy,
                currencyFormat: _currencyFormat,
                onRefresh: () => setState(_load),
              ),

              // Các công trình
              ...vm.thuChiCongTrinhs.map((ct) => CongTrinhSection(
                congTrinhVM: ct,
                currencyFormat: _currencyFormat,
                onRefresh: () => setState(_load),
              )),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ThemThuChiScreen()),
          );
          if (result == true) {
            setState(_load); // refresh danh sách khi thêm mới
          }
        },
      ),
    );
  }

}
