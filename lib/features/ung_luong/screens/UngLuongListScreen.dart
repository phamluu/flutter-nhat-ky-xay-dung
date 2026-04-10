// Danh sách ứng lương trong 1 tháng của tất cả nhân viên công trình
import 'package:flutter/material.dart';

import '../../../core/utils/currencyFormat.dart';
import '../../../data/models/UngLuong.dart';
import '../../../services/ung_luong_service.dart';
import 'UngLuongScreen.dart';

class UngLuongListScreen extends StatefulWidget {
  final int idCongTrinh;
  final String? tenCongTrinh;
  const UngLuongListScreen({super.key, required this.idCongTrinh,
    this.tenCongTrinh});

  @override
  State<UngLuongListScreen> createState() => _UngLuongListScreenState();
}

class _UngLuongListScreenState extends State<UngLuongListScreen> {
  final service = UngLuongService();

  int thang = DateTime.now().month;
  int nam = DateTime.now().year;

  List<UngLuongViewModel> data = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final result =
    await service.getDanhSach(widget.idCongTrinh, thang, nam);
    setState(() => data = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Column(
        children: [
          Text("Ứng lương $thang/$nam"),
          Text((widget.tenCongTrinh ?? ''), style: TextStyle(fontSize: 16),)
        ],
      )),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _filter(),
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (_, i) {
                  final item = data[i];
                  return _buildNhanVienItem(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildNhanVienItem(UngLuongViewModel item){
     return Card(
       elevation: 1,
       margin: const EdgeInsets.symmetric(vertical: 6),
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(12),
       ),
       child: ListTile(
         title: Text(item.hoTen ?? ""),
         trailing: Text("${formatCurrency(item.tongUng)} đ"),
         onTap: () async {
           await Navigator.push(
             context,
             MaterialPageRoute(
               builder: (_) => UngLuongScreen(
                 idNhanVienCongTrinh: item.idNhanVienCongTrinh,
                 hoTen: item.hoTen,
                 congTrinh: widget.tenCongTrinh,
                 thang: thang,
                 nam: nam,
               ),
             ),
           );
           loadData(); // reload lại sau khi thêm/sửa
         },
       ),
     );
  }
  Widget _filter() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: thang,
                  isExpanded: true,
                  items: List.generate(12, (i) => i + 1)
                      .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text("Tháng $e"),
                  ))
                      .toList(),
                  onChanged: (v) {
                    setState(() => thang = v!);
                    loadData();
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: nam,
                  isExpanded: true,
                  items: List.generate(5, (i) => 2023 + i)
                      .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text("Năm $e"),
                  ))
                      .toList(),
                  onChanged: (v) {
                    setState(() => nam = v!);
                    loadData();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}