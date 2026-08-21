import 'package:flutter/material.dart';

import '../../../../../core/utils/currencyFormat.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../../data/models/ThuChi.dart';

class ThuChiDetailDesktop extends StatelessWidget {
  final ThuChi tc;

  const ThuChiDetailDesktop({
    super.key,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    final bool isThu = tc.loai == 1;

    final Color primaryColor = isThu
        ? const Color(0xff16a34a)
        : const Color(0xffdc2626);

    final Color lightColor = isThu
        ? const Color(0xffecfdf3)
        : const Color(0xfffef2f2);

    return Scaffold(
      backgroundColor: const Color(0xfff4f6f8),

      // ==========================================================
      // TOP BAR
      // ==========================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff172033),

        titleSpacing: 24,

        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: lightColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isThu
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                size: 19,
                color: primaryColor,
              ),
            ),

            const SizedBox(width: 11),

            Text(
              isThu ? 'Chi tiết khoản thu' : 'Chi tiết khoản chi',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(
                  isThu: isThu,
                  primaryColor: primaryColor,
                  lightColor: lightColor,
                ),

                const SizedBox(height: 20),

                _buildInformationCard(
                  isThu: isThu,
                  primaryColor: primaryColor,
                ),

                const SizedBox(height: 20),

                _buildNoteCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader({
    required bool isThu,
    required Color primaryColor,
    required Color lightColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: lightColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isThu
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              size: 29,
              color: primaryColor,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: lightColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isThu ? 'KHOẢN THU' : 'KHOẢN CHI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  currencyFormat.format(tc.soTien),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  DateUtilsCore.formatDate(tc.ngay),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // ID giao dịch
          if (tc.id != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xfff8fafc),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                'ID: ${tc.id}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xff64748b),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // INFORMATION
  // ==========================================================

  Widget _buildInformationCard({
    required bool isThu,
    required Color primaryColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin giao dịch',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xff172033),
            ),
          ),

          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 650) {
                return Column(
                  children: [
                    _buildInfoItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Ngày giao dịch',
                      value: DateUtilsCore.formatDate(
                        tc.ngay,
                      ),
                      color: primaryColor,
                    ),
                    const SizedBox(height: 18),
                    _buildInfoItem(
                      icon: Icons.folder_outlined,
                      label: 'Danh mục',
                      value:
                      tc.danhMucThuChi?.ten ??
                          'Không có',
                      color: primaryColor,
                    ),
                    const SizedBox(height: 18),
                    _buildInfoItem(
                      icon: Icons.business_outlined,
                      label: 'Công trình',
                      value:
                      tc.congTrinh?.ten ??
                          'Không có',
                      color: primaryColor,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Ngày giao dịch',
                      value: DateUtilsCore.formatDate(
                        tc.ngay,
                      ),
                      color: primaryColor,
                    ),
                  ),

                  const SizedBox(width: 30),

                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.folder_outlined,
                      label: 'Danh mục',
                      value:
                      tc.danhMucThuChi?.ten ??
                          'Không có',
                      color: primaryColor,
                    ),
                  ),

                  const SizedBox(width: 30),

                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.business_outlined,
                      label: 'Công trình',
                      value:
                      tc.congTrinh?.ten ??
                          'Không có',
                      color: primaryColor,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff334155),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // NOTE
  // ==========================================================

  Widget _buildNoteCard() {
    final note = tc.ghiChu?.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.notes_outlined,
                size: 19,
                color: Color(0xff64748b),
              ),

              SizedBox(width: 8),

              Text(
                'Ghi chú',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff172033),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xfff8fafc),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              note?.isNotEmpty == true
                  ? note!
                  : 'Không có ghi chú cho khoản thu chi này.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: note?.isNotEmpty == true
                    ? const Color(0xff475569)
                    : const Color(0xff94a3b8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}