import 'package:flutter/material.dart';

import '../../../../../core/utils/currencyFormat.dart';
import '../../../data/models/ThuChi.dart';

Widget buildTamUngChiLuongMobile(
    ThuChiCongTrinhViewModel vm,
    ) {
  return Container(
    margin: const EdgeInsets.fromLTRB(
      14,
      14,
      14,
      14,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 13,
          ),
          decoration: const BoxDecoration(
            color: Color(0xfff8fafc),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xfff1f5f9),
                  borderRadius:
                  BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.money,
                  size: 19,
                  color: Color(0xff64748b),
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'Lương',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff1e293b),
                  ),
                ),
              ),
              const Text(
                'Số dư',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xff94a3b8),
                ),
              ),
              const SizedBox(width: 8,),
              Text(
                '-${formatCurrency(vm.tamUngLuong + vm.daChiLuong)}',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xffdc2626)
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              buildChiLuongItem(title: 'Tạm ứng', soTien: formatCurrency(vm.tamUngLuong) ),
              buildChiLuongItem(title: 'Chi lương', soTien: formatCurrency(vm.daChiLuong))
            ],
          ),
        ),
      ],
    ),
  );
}
Widget buildChiLuongItem({String title='', String soTien = ''}) {
  final Color typeColor = const Color(0xffdc2626);
  final Color typeBackground = const Color(0xfffef2f2);

  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color:  Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:  const Color(0xffedf0f3),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => {},
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 6,
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: typeBackground,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(Icons.arrow_upward_rounded,
                  size: 10,
                  color: typeColor,
                ),
              ),

              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: typeBackground,
                            borderRadius:
                            BorderRadius.circular(5),
                          ),
                          child: Text('CHI',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: typeColor,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(title,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ==================================================
              // SỐ TIỀN
              // ==================================================

              SizedBox(
                width: 100,
                child: Text(
                  soTien,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: typeColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}