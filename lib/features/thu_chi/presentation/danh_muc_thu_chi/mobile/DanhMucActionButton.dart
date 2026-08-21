import 'package:flutter/material.dart';
import '../../../data/models/DanhMucThuChi.dart';
import 'them_danh_muc_thu_chi_mobile.dart';

class OpenFormButton extends StatelessWidget {
  final DanhMucThuChi? danhMuc;
  final VoidCallback onUpdated;

  const OpenFormButton({super.key, this.danhMuc, required this.onUpdated});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ThemDanhMucThuChiScreen(danhMuc: danhMuc),
          ),
        );

        if (result == true) {
          onUpdated();
        }
      },
    );
  }
}
