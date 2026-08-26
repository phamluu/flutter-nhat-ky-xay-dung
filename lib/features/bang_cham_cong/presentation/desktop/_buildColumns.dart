import 'package:flutter/material.dart';

import 'isShowNgay.dart';

List<DataColumn> buildColumns(int soNgay, bool _showChucVu, bool _show10Dau,  bool _show10Giua,  bool _show10Cuoi) {
  final columns = <DataColumn>[];
  columns.add(
    const DataColumn(
      label: SizedBox(
        width: 170,
        child: Text(
          "HỌ TÊN",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    ),
  );
  if (_showChucVu) {
    columns.add(
      const DataColumn(
        label: SizedBox(
          width: 110,
          child: Text(
            "CHỨC VỤ",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  for (int i = 1; i <= soNgay; i++) {
    if (isShowNgay(i, _show10Dau,  _show10Giua,  _show10Cuoi)) {
      columns.add(
        DataColumn(
          numeric: true,
          label: SizedBox(
            width: 35,
            child: Center(
              child: Text(
                "$i",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
  columns.add(
    const DataColumn(
      label: Text(
        "TỔNG CÔNG",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    ),
  );
  columns.add(
    const DataColumn(
      label: Text(
        "TỔNG LƯƠNG",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    ),
  );
  columns.add(
    const DataColumn(
      label: Text( "ĐÃ ỨNG", style: TextStyle( fontWeight: FontWeight.w700, fontSize: 12, ),
      ),
    ),
  );
  columns.add(
    const DataColumn(
      label: Text( "TRỪ ỨNG", style: TextStyle( fontWeight: FontWeight.w700,fontSize: 12,),
      ),
    ),
  );
  columns.add(
    const DataColumn(
      label: Text( "THỰC NHẬN",style: TextStyle( fontWeight: FontWeight.w700, fontSize: 12, ),
      ),
    ),
  );
  columns.add(
    const DataColumn(
      label: Text(
        "CHỐT LƯƠNG", style: TextStyle( fontWeight: FontWeight.w700, fontSize: 12,
        ),
      ),
    ),
  );
  columns.add(
    const DataColumn(
      label: Text(
        "CHI LƯƠNG", style: TextStyle( fontWeight: FontWeight.w700, fontSize: 12,
        ),
      ),
    ),
  );
  return columns;
}