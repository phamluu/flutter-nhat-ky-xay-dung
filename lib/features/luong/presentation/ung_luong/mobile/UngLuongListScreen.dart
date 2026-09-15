// Danh sách ứng lương trong 1 tháng của tất cả nhân viên công trình
import 'package:flutter/material.dart';
import '../../../../../core/utils/currencyFormat.dart';
import '../../../data/models/UngLuong.dart';
import '../../../data/repositories/ung_luong_repository.dart';
import '../widgets/_buildDropdown.dart';
import 'UngLuongScreen.dart';

class UngLuongListMobile extends StatefulWidget {
  final int idCongTrinh;
  final String? tenCongTrinh;
  final int? idBangChamCong;
  const UngLuongListMobile({super.key, required this.idCongTrinh,
    this.tenCongTrinh, this.idBangChamCong
  });
  @override
  State<UngLuongListMobile> createState() => _UngLuongListScreenState();
}

class _UngLuongListScreenState extends State<UngLuongListMobile> {
  final service = UngLuongRepository();
  int thang = DateTime.now().month;
  int nam = DateTime.now().year;
  String? kyLuong;
  List<Map<String, dynamic>> kyLuongs = [];
  List<UngLuongViewModel> data = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final result = await service.getDanhSach(widget.idCongTrinh, kyLuong: kyLuong);
    final search = await service.getKyLuongs(widget.idCongTrinh);
    setState((){
      data = result;
      kyLuongs = search;});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Column(
        children: [
          Text("Danh sách ứng lương ${kyLuong ?? ''}"),
          SizedBox(height: 6,),
          Text((widget.tenCongTrinh ?? ''), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),)
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
                 kyLuong: kyLuong,
                 idBangChamCong: null,
               ),
             ),
           );
           loadData(); // reload lại sau khi thêm/sửa
         },
       ),
     );
  }
  Widget _filter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          buildDropdown<String?>(
            width: 400,
            icon: Icons.calendar_month_outlined,
            label: "Kỳ lương",
            value: kyLuong,
            items: [
              null,
              ...kyLuongs
                  .map((e) => e['value']?.toString())
                  .whereType<String>(),
            ],
            itemLabel: (value) {
              if (value == null) {
                return "Tất cả kỳ lương";
              }
              for (final item in kyLuongs) {
                if (item['value']?.toString() == value) {
                  return item['label']?.toString() ?? value;
                }
              }
              return value;
            },
            onChanged: (value) {
              setState(() {
                kyLuong = value;
              });
              loadData();
            },
          ),
          SizedBox(height: 5,),
          // THÔNG TIN THỜI GIAN
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(.08),
              borderRadius:
              BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 17,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 7),
                Text(
                  "Kỳ ứng: ${kyLuong ?? 'Cả công trình'}",
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}