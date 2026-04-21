import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/utils/trang_thai_cham_cong.dart';
import 'package:nhat_ky_xay_dung/core/utils/trang_thai_khoa_cong.dart';

import '../../../core/utils/trang_thai_luong.dart';
import '../../../services/ChotChiLuongService.dart';
import '../../../viewmodel/ChamCongModel.dart';
import '../../chi_luong/ChiLuongScreen.dart';
import 'chiLuongbtn.dart';
import 'chot_luong_dialog.dart';
import 'huyChotLuongBtn.dart';

class BangLuongActionCell extends StatelessWidget {
  final ChamCongModel nv;
  final int thang;
  final int nam;
  final Chotchiluongservice service;
  final bool daKhoaCC;
  final Future<void> Function() onReload;

  const BangLuongActionCell({
    super.key,
    required this.nv,
    required this.thang,
    required this.nam,
    required this.service,
    required this.daKhoaCC,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    final trangthai = TrangThaiLuong.fromValue(nv.trangThai);
    if (trangthai == TrangThaiLuong.dachot) {
      if (nv.tongDaChi == 0) {
        return Row(
          children: [
            HuyChotLuongButton(
              nv: nv,
              service: service,
              onReload: onReload,
            ),
            const SizedBox(width: 3,),
            ChiLuongButton(
              nv: nv,
              onReload: onReload,
            ),
          ],
        );
      }
      return ChiLuongButton(
        nv: nv,
        onReload: onReload,
      );
    }

    return ElevatedButton(
      onPressed: () async {
        await ChotLuongHelper.showConfirmChot(
          context: context,
          nv: nv,
          thang: thang,
          nam: nam,
          service: service,
          onSuccess: onReload,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 20),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text("Chốt", style: TextStyle(color: Colors.white),),
    );
  }
}

class ChiLuongButton extends StatelessWidget {
  final ChamCongModel nv;
  final Future<void> Function() onReload;

  const ChiLuongButton({
    super.key,
    required this.nv,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChiLuongScreen(
              idBangLuong: nv.idBangLuong!,
              tenNhanVien: nv.ten,
              tongPhaiTra: nv.thucNhanHienThi ?? 0,
            ),
          ),
        );

        if (result == true) {
          await onReload();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 20),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        "Chi lương",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class HuyChotLuongButton extends StatelessWidget {
  final ChamCongModel nv;
  final Chotchiluongservice service;
  final Future<void> Function() onReload;

  const HuyChotLuongButton({
    super.key,
    required this.nv,
    required this.service,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await ChotLuongHelper.showConfirmHuyChot(
          context: context,
          idBangLuong: nv.idBangLuong!,
          service: service,
          onSuccess: () async {
            await onReload();
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 20),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        "Hủy chốt",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class ChotLuongHelper {
  static Future<void> showConfirmChot({
    required BuildContext context,
    required ChamCongModel nv,
    required int thang,
    required int nam,
    required Chotchiluongservice service,
    required VoidCallback onSuccess,
  }) async {
    final ok = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận"),
        content: Text("Chốt lương cho ${nv.ten}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Huỷ"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Chốt"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await service.chotLuong(
        nv: nv,
        thang: thang,
        nam: nam,
      );

      onSuccess();
    }
  }

  static Future<void> showConfirmHuyChot({
    required BuildContext context,
    required int idBangLuong,
    required Chotchiluongservice service,
    required VoidCallback onSuccess,
  }) async {
    final ok = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Hủy chốt lương"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Huỷ"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hủy chốt"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await service.huyChot(idBangLuong: idBangLuong);
      onSuccess();
    }
  }
}