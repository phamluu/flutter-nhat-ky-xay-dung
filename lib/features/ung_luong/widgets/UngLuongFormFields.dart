import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class UngLuongFormFields extends StatelessWidget {
  final TextEditingController soTienCtrl;
  final TextEditingController lyDoCtrl;
  final DateTime? ngayUng;
  final void Function(DateTime) onSelectDate;

  const UngLuongFormFields({
    Key? key,
    required this.soTienCtrl,
    required this.lyDoCtrl,
    this.ngayUng,
    required this.onSelectDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: soTienCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Số tiền'),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final dt = await showDatePicker(
              context: context,
              initialDate: ngayUng ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (dt != null) onSelectDate(dt);
          },
          child: InputDecorator(
            decoration: const InputDecoration(labelText: 'Ngày ứng'),
            child: Text(ngayUng != null
                ? DateFormat('dd/MM/yyyy').format(ngayUng!)
                : 'Chọn ngày'),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: lyDoCtrl,
          decoration: const InputDecoration(labelText: 'Lý do'),
        ),
      ],
    );
  }
}
