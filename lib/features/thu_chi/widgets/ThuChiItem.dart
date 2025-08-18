import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:nhat_ky_xay_dung/features/thu_chi/screens/ThuChiDetailScreen.dart';
import '../../../core/utils/currencyFormat.dart';
import '../../../data/models/ThuChi.dart';
import 'thu_chi_button.dart';

class ThuChiItem extends StatelessWidget {
  final ThuChi tc;
  final VoidCallback onRefresh;

  const ThuChiItem({
    super.key,
    required this.tc,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {

    return Slidable(
      key: ValueKey(tc.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.4,
        children: [
          SlidableAction(
            onPressed: (_) =>
                openThuChiForm(context, tc, () => onRefresh()),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Sửa',
          ),
          SlidableAction(
            onPressed: (_) =>
                deleteThuChi(context, tc.id!, () => onRefresh()),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Xóa',
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade50, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          title: Text("${tc.loai == 1 ? "Thu" : "Chi"}: ${currencyFormat.format(tc.soTien)}"),
          subtitle: Text(tc.ghiChu ?? ""),
            onTap: () async{
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ThuChiDetailScreen(tc: tc),
                ),
              );

              if (result == true) {
                // setState(() {
                //   _loadData();
                // });
              }
            }
        ),
      ),
    );
  }
}

