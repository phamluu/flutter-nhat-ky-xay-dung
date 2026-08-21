import 'package:flutter/material.dart';

import '../../../../../core/utils/currencyFormat.dart';
import '../../../data/models/ThuChi.dart';
import 'summaryCard.dart';

Widget buildSummary(
    ThuChiCongTrinhViewModel vm,
    ) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final cardWidth =
          (constraints.maxWidth - 32) / 3;

      if (constraints.maxWidth < 720) {
        return Column(
          children: [
            summaryCard(
              title: 'Tổng thu',
              value: formatCurrency(vm.tongThu),
              icon: Icons.arrow_downward_rounded,
              color: const Color(0xff16a34a),
              background:
              const Color(0xffecfdf3),
            ),

            const SizedBox(height: 12),

            summaryCard(
              title: 'Tổng chi',
              value: currencyFormat.format(
                  vm.tongChi
              ),
              icon: Icons.arrow_upward_rounded,
              color: const Color(0xffdc2626),
              background:
              const Color(0xfffef2f2),
            ),

            const SizedBox(height: 12),

            summaryCard(
              title: 'Còn lại',
              value: currencyFormat.format(
                vm.conLai,
              ),
              icon: Icons
                  .account_balance_wallet_outlined,
              color: vm.conLai >= 0
                  ? const Color(0xff2563eb)
                  : const Color(0xffdc2626),
              background: vm.conLai >= 0
                  ? const Color(0xffeff6ff)
                  : const Color(0xfffef2f2),
            ),
          ],
        );
      }

      return Row(
        children: [
          SizedBox(
            width: cardWidth,
            child: summaryCard(
              title: 'Tổng thu',
              value: currencyFormat.format(
                vm.tongThu,
              ),
              icon: Icons.arrow_downward_rounded,
              color: const Color(0xff16a34a),
              background:
              const Color(0xffecfdf3),
            ),
          ),

          const SizedBox(width: 16),

          SizedBox(
            width: cardWidth,
            child: summaryCard(
              title: 'Tổng chi',
              value: currencyFormat.format(
                vm.tongChi,
              ),
              icon: Icons.arrow_upward_rounded,
              color: const Color(0xffdc2626),
              background:
              const Color(0xfffef2f2),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: summaryCard(
              title: 'Còn lại',
              value: currencyFormat.format(
                vm.conLai,
              ),
              icon: Icons
                  .account_balance_wallet_outlined,
              color: vm.conLai >= 0
                  ? const Color(0xff2563eb)
                  : const Color(0xffdc2626),
              background: vm.conLai >= 0
                  ? const Color(0xffeff6ff)
                  : const Color(0xfffef2f2),
            ),
          ),
        ],
      );
    },
  );
}