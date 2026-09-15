import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/bang_cham_cong_repo.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/presentation/desktop/bang_cham_cong_desktop.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/presentation/mobile/bang_cham_cong_mobile.dart';

import '../../../../core/utils/SyncColor.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/trang_thai_khoa_cong.dart';
import '../../data/models/bang_cham_cong.dart';
import 'bang_cham_cong_form_mobile.dart';

class BangChamCongListMobile extends StatefulWidget {
  final int? idCongTrinh;
  final String? tenCongTrinh;
  const BangChamCongListMobile({super.key, this.idCongTrinh, this.tenCongTrinh});
  @override
  State<BangChamCongListMobile> createState() =>
      _BangChamCongListDesktopState();
}
class _BangChamCongListDesktopState extends State<BangChamCongListMobile> {
  final _repo = BangChamCongRepository();
  late Future<List<BangChamCong>> _future;
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  @override
  void dispose() {
    super.dispose();
  }
  void _loadData() {
    setState(() {
      _future = _repo.getByCongTrinh(widget.idCongTrinh);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6f8),
      appBar: AppBar(
        title: _buildHeader(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<BangChamCong>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child:
                        CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      return _buildError(
                        snapshot.error.toString(),
                      );
                    }
                    final data = snapshot.data ?? [];
                    if (data.isEmpty) {
                      return _buildEmpty();
                    }
                    return _buildTable(data, widget.tenCongTrinh );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteCongTrinh(BangChamCong chamCong) async
  {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text(
            'Bạn có chắc muốn xóa bảng chấm công ${chamCong.thang} ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
              child: const Text('Hủy'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(ctx, true);
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    try {
      await _repo.delete(idBangChamCong: chamCong.id);
      if (!mounted) return;
      showSuccessToast(context, 'Xóa bảng chấm công thành công');
      _loadData();
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, e, 'Không thể xóa bảng chấm công: ');
    }
  }
  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment:CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Bảng chấm công',
                style: TextStyle( fontSize: 26,fontWeight: FontWeight.bold, ),
              ),
              const SizedBox(height: 4),
              Text(
                'Công trình ${widget.tenCongTrinh}',
                style: const TextStyle(color: Colors.grey,fontSize: 14,
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),

        FilledButton.icon(
          onPressed:  _openThemBangChamCong,
          icon: const Icon(Icons.add),
          label: const Text( 'Thêm mới', ),
        ),
      ],
    );
  }

  Widget _buildTable(
      List<BangChamCong> data,
      String? tenCongTrinh,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            _buildTableHeader(),
            Expanded(
              child: ListView.separated(
                itemCount: data.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: Colors.grey.shade200,
                ),
                itemBuilder: (context, index) {
                  return _buildTableRow(
                    index,
                    data[index],
                    tenCongTrinh,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTableHeader() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          const SizedBox(
            width: 50,
            child: Text(
              'STT',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Bảng chấm công',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
      int index,
      BangChamCong ct,
      String? tenCongTrinh,
      ) {
    return Slidable(
      key: ValueKey(ct.id),

      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.45,
        children: [
          SlidableAction(
            onPressed: (_) {
              _openChiTiet(ct, tenCongTrinh);
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.visibility_outlined,
            label: 'Xem',
          ),
          SlidableAction(
            onPressed: (_) {
              _deleteCongTrinh(ct);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Xóa',
          ),
        ],
      ),

      child: InkWell(
        onDoubleTap: () {
          _openChiTiet(ct, tenCongTrinh);
        },
        onTap: () {
          _openChiTiet(ct, tenCongTrinh);
        },
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 82,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  (index + 1).toString(),
                ),
              ),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bảng chấm công tháng '
                          '${ct.thang}/${ct.nam}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateUtilsCore.formatDate(ct.ngayTao),
                      style: const TextStyle(
                        color: Colors.black26,
                      ),
                    ),
                  ],
                ),
              ),

              // Gợi ý cho người dùng biết có thể vuốt
              const Icon(
                Icons.swipe_left_outlined,
                size: 20,
                color: Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _openThemBangChamCong() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BangChamCongFormMobile(
          bangChamCong: BangChamCong(idCongTrinh: widget.idCongTrinh),
        ),
      ),
    );

    if (result == true && mounted) {
      _loadData();
    }
  }
  Future<void> _openChiTiet(BangChamCong ct, String? tenCongTrinh) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BangChamCongMobile(
          bangChamCong: ct,
          tenCongTrinh: tenCongTrinh,
        ),
      ),
    );
    if (result == true && mounted) {
      _loadData();
    }
  }
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          const Text(
            'Chưa có bảng chấm công nào',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,),
          ),
          const SizedBox(height: 6),
          Text(
            'Hãy thêm bảng chấm công đầu tiên',
            style: TextStyle( color: Colors.grey.shade600,),
          ),
        ],
      ),
    );
  }

  Widget _buildError( String error,) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          const Text(
            'Không thể tải danh sách bảng chấm công',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error, style: const TextStyle( color: Colors.grey),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}