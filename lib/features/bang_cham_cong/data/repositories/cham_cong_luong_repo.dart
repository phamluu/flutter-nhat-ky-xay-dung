import 'package:nhat_ky_xay_dung/core/utils/trang_thai_khoa_cong.dart';
import 'package:nhat_ky_xay_dung/core/utils/trang_thai_luong.dart';
import 'package:nhat_ky_xay_dung/data/tables/cham_cong_chi_tiet_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/cham_cong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/ky_luong_table.dart';
import 'package:nhat_ky_xay_dung/features/luong/data/enums.dart';

import '../../../../data/db_helper.dart';

class ChamCongLuongRepo {
  final _dbHelper = DBHelper.instance;

  Future<void>DeleteData(int? idBangChamCong) async{
    final db = await _dbHelper.database;
    // Kiểm tra bảng chấm công đang khóa => không được xóa
    // Kiểm tra tồn tại kỳ lương đã chốt => không được xóa
    final results = await Future.wait([
        db.query(ChamCongTable.tableName,
                columns: [ChamCongTable.id],
                where: '${ChamCongTable.id} = ? AND ${ChamCongTable.daKhoa} = ${TrangThaiKhoaChamCong.dakhoa.value}',
                whereArgs: [idBangChamCong],
                limit: 1
                ),
      db.query(KyLuongTable.tableName,
          columns: [KyLuongTable.id],
          where: '${KyLuongTable.idBangChamCong} = ? AND ${KyLuongTable.trangThai} = ?',
          whereArgs: [idBangChamCong, TrangThaiLuong.dachot.value],
          limit: 1
      )
    ]);
    if(results[0].isNotEmpty){
      throw Exception('Bảng chấm đã khóa. Hãy mở khóa chấm công trước');
    }
    if(results[1].isNotEmpty){
      throw Exception('Bảng chấm công còn tồn tại dữ liệu kỳ lương đã chốt. Hãy hủy chốt lương trước');
    }
    try{
      await db.delete(KyLuongTable.tableName, where: '${KyLuongTable.idBangChamCong} = ?',
          whereArgs: [idBangChamCong]);
      await db.delete(ChamCongChiTietTable.tableName, where: '${ChamCongChiTietTable.idChamCong} = ?',
          whereArgs: [idBangChamCong]);
    }catch(e){
      throw Exception('Lỗi: Không thể xóa');
    }
  }
}