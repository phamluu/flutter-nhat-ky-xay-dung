import 'package:flutter/material.dart';

import '../../../../../core/utils/currencyFormat.dart';

Widget tableCell(Widget child) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: child,
  );
}
class TableHeader extends StatelessWidget {
  final String title;
  const TableHeader(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
InputDecoration tableInputDecoration({String? hintText,}) {
  return InputDecoration(
    hintText: hintText,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 10,
    ),
    filled: true,
    fillColor: const Color(0xfffafafa),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(
        color: Colors.grey.shade300,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(
        color: Colors.grey.shade300,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(
        color: Colors.blue.shade600,
        width: 1.5,
      ),
    ),
  );
}

class HangHoaInput {
  late final TextEditingController tenController;
  late final TextEditingController donViController;
  late final TextEditingController soLuongController;
  late final TextEditingController donGiaController;

  HangHoaInput({
    String ten = '',
    String donVi = '',
    String soLuong = '',
    String donGia = '',
  }) {
    tenController = TextEditingController(text: ten);
    donViController = TextEditingController(text: donVi);
    soLuongController = TextEditingController(text: soLuong);
    donGiaController = TextEditingController(text: donGia);
  }

  double get thanhTien {
    final sl = double.tryParse(soLuongController.text) ?? 0;
    final dg = parseCurrency(donGiaController.text);
    return sl * dg;
  }
  // Getter parse đơn giá từ controller
  double get donGia => parseCurrency(donGiaController.text);
  String? get donVi => donViController.text;
  // Getter parse số lượng từ controller
  double get soLuong => double.tryParse(soLuongController.text) ?? 0;
  void dispose() {
    tenController.dispose();
    donViController.dispose();
    soLuongController.dispose();
    donGiaController.dispose();
  }
}

