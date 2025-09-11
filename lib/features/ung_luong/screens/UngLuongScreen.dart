import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nhat_ky_xay_dung/data/models/NhanVienCongTrinh.dart';
import 'package:nhat_ky_xay_dung/services/nhan_vien_cong_trinh_service.dart';
import 'package:nhat_ky_xay_dung/services/nhan_vien_service.dart';
import '../../../core/utils/currencyFormat.dart';
import '../../../data/models/NhanVien.dart';
import '../../../data/models/UngLuong.dart';
import '../../../services/ung_luong_service.dart';
import '../widgets/ung_luong_helper.dart';
import 'UngLuongFormDialog.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
class UngLuongScreen extends StatefulWidget {
  final int? idCongTrinh;
  final String? tenCongTrinh;
  const UngLuongScreen({Key? key, this.idCongTrinh, this.tenCongTrinh}) : super(key: key);

  @override
  State<UngLuongScreen> createState() => _UngLuongScreenState();
}

class _UngLuongScreenState extends State<UngLuongScreen> {
  List<Ungluong> _list = [];
  List<NhanVien> nhanViens = [];
  List<NhanVienCongTrinh> nhanVienCongTrinhs = [];
  late final UngLuongService service;
  late final NhanVienService _nhanVienService;
  late final NhanVienCongTrinhService _nhanVienCongTrinhService;
  bool _isLoadingNhanViens = true;
  @override
  void initState() {
    super.initState();
    service = UngLuongService();
    _nhanVienService = NhanVienService();
    _nhanVienCongTrinhService = NhanVienCongTrinhService();

    _loadData();
    _loadNhanViens();
    _loadNhanVienCongTrinhs();
  }
  Future<void> _loadNhanViens() async {
    nhanViens = await _nhanVienService.getAllNhanVien();
    setState(() => _isLoadingNhanViens = false);
  }
  Future<void> _loadNhanVienCongTrinhs() async {
    nhanVienCongTrinhs = await _nhanVienCongTrinhService.getAll();
    setState(() => _isLoadingNhanViens = false);
  }
  Future<void> _loadData() async {
    List<Ungluong> data;

    if (widget.idCongTrinh != null) {
      data = await service.getUngLuongCongTrinh(widget.idCongTrinh);
    } else {
      data = await service.getAllUngLuong();
    }

    setState(() => _list = data);
  }

  Map<String, List<Ungluong>> _groupByMonthYear(List<Ungluong> list) {
    final Map<String, List<Ungluong>> grouped = {};
    final dateFormat = DateFormat('MM/yyyy');

    for (var u in list) {
      final key = u.ngayUng != null ? dateFormat.format(u.ngayUng!) : "Chưa có ngày";
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(u);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedData = _groupByMonthYear(_list);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Quản lý ứng lương",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (widget.idCongTrinh != null)
              Text(
                widget.tenCongTrinh ?? "",
                style: const TextStyle(fontSize: 13, color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
      body: ListView(
        children: groupedData.entries.map((entry) {
          final monthYear = entry.key;
          final items = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header nhóm (Tháng/Năm)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.grey.shade300,
                child: Text('Chi lương tháng ' + monthYear,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Danh sách ứng lương trong tháng
              ...items.asMap().entries.map((e) {
                final index = e.key;
                final u = e.value;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Slidable(
                    key: ValueKey(u.id),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 0.4,
                      children: [
                        SlidableAction(
                          onPressed: (_) async {
                            UngLuongHelper.showFormDialog(
                              context: context,
                              ungLuong: u,
                              nhanViens: nhanViens,
                              nhanVienCongTrinhs: nhanVienCongTrinhs,
                              service: service,
                              idCongTrinh: widget.idCongTrinh,
                              onSuccess: _loadData,
                            );
                          },
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: 'Sửa',
                        ),
                        SlidableAction(
                          onPressed: (_) => UngLuongHelper.deleteUngLuong(
                            context: context,
                            ungLuong: u,
                            service: service,
                            onSuccess: () {
                              setState(() {
                                _list.removeWhere((item) => item.id == u.id);
                              });
                            },
                          ),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Xóa',
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        '${u.nhanVien?.hoTen ?? 'Không tên'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black87, fontSize: 14),
                          children: [
                            const TextSpan(text: 'Số tiền: '),
                            TextSpan(
                              text: currencyFormat.format(u.soTien ?? 0),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                fontSize: 15,
                              ),
                            ),
                            TextSpan(
                              text:
                              '\nCông trình: ${u.nhanVienCongTrinh?.congTrinh?.ten ?? "Không có"}'
                                  '\nNgày ứng: ${u.ngayUng != null ? DateFormat('dd/MM/yyyy').format(u.ngayUng!) : "Chưa có"}'
                                  '\nLý do: ${u.lyDo ?? ""}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        }).toList(),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.blue,
        overlayOpacity: 0.4,
        spacing: 12,
        spaceBetweenChildren: 8,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.attach_money, color: Colors.white),
            backgroundColor: Colors.green,
            label: 'Ứng lương',
            onTap: () => UngLuongHelper.showFormDialog(
              context: context,
              nhanViens: nhanViens,
              nhanVienCongTrinhs: nhanVienCongTrinhs,
              service: service,
              onSuccess: _loadData,
              idCongTrinh: widget.idCongTrinh
            ),
          ),
          SpeedDialChild(
            child: const Icon(Icons.picture_as_pdf, color: Colors.white),
            backgroundColor: Colors.red,
            label: 'Xuất PDF',
            onTap: () => UngLuongHelper.export(_list),
          ),
        ],
      ),
    );
  }

}
