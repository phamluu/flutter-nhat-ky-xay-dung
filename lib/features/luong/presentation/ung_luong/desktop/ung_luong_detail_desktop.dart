import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/luong/data/models/UngLuong.dart';

import '../../../../../core/utils/currencyFormat.dart';
import '../../../../../core/utils/date_utils.dart';

class UngLuongDetailDesktop extends StatefulWidget {
  final Ungluong model;

  const UngLuongDetailDesktop({
    super.key,
    required this.model,
  });

  @override
  State<UngLuongDetailDesktop> createState() =>
      _UngLuongDetailDesktopState();
}

class _UngLuongDetailDesktopState
    extends State<UngLuongDetailDesktop> {

  Ungluong get model => widget.model;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        title: const Text(
          'Chi tiết ứng lương',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverview(),
            const SizedBox(height: 20),
            _buildInfo(),
            const SizedBox(height: 20),
            _buildDoiTru(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview() {
    return Row(
      children: [
        Expanded(
          child: _moneyCard(
            title: 'Số tiền ứng',
            value: model.soTien ?? 0,
            icon: Icons.payments_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _moneyCard(
            title: 'Đã đối trừ',
            value: model.tongDaTru,
            icon: Icons.remove_circle_outline,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _moneyCard(
            title: 'Còn lại',
            value: model.conLai,
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
      ],
    );
  }

  Widget _moneyCard({
    required String title,
    required double value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle( fontSize: 12, color: Color(0xFF6B7280), ),
              ),
              const SizedBox(height: 5),
              Text(
                formatCurrency(value),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return _card(
      title: 'Thông tin khoản ứng',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _infoRow(
            'Ngày ứng',DateUtilsCore.formatDate(model.ngayUng.toString()),
          ),
          const Divider(height: 24),
          _infoRow( 'Lý do', model.lyDo?.isNotEmpty == true ? model.lyDo! : 'Không có',),
          const Divider(height: 24),
          _infoRow(
            'Trạng thái',
            _buildTrangThai(),
          ),
        ],
      ),
    );
  }

  Widget _infoRow( String label, dynamic value,) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle( fontSize: 13, color: Color(0xFF6B7280), ),
          ),
        ),
        Expanded(
          child: value is Widget
              ? value
              : Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrangThai() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _trangThaiText(model.trangThai),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _trangThaiText(int? value) {
    switch (value) {
      case 1:
        return 'Đã ứng';
      case 2:
        return 'Đã đối trừ';
      case 3:
        return 'Đã hoàn tất';
      default:
        return 'Không xác định';
    }
  }

  Widget _buildDoiTru() {
    final list = model.lstDoiTru ?? [];

    return _card(
      title: 'Lịch sử đối trừ',
      icon: Icons.history,
      trailing: Text(
        '${list.length} lần',
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF6B7280),
        ),
      ),
      child: list.isEmpty
          ? const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Text(
            'Chưa có khoản đối trừ nào',
            style: TextStyle(
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      )
          : Column(
        children: [
          _buildTableHeader(),
          const Divider(height: 1),
          ...list.asMap().entries.map(
                (entry) => _buildDoiTruRow(
              entry.key + 1,
              entry.value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 8,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              '#',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Ngày đối trừ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          SizedBox(
            width: 180,
            child: Text(
              'Số tiền',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          SizedBox(
            width: 180,
            child: Text(
              'Kỳ lương',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoiTruRow( int index, dynamic item,) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 14,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              '$index',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          // Ngày đối trừ
          Expanded(
            child: Text(DateUtilsCore.formatDate(item.ngayDoiTru.toString()),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF111827),
              ),
            ),
          ),
          // Số tiền
          SizedBox(
            width: 180,
            child: Text(
              formatCurrency(item.soTienDoiTru ?? 0),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
          // Kỳ lương
          SizedBox(
            width: 180,
            child: Text('Tháng ${item.thang}/${item.nam}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: const Color(0xFF374151), ),
              const SizedBox(width: 8),
              Text( title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827), ),
              ),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}