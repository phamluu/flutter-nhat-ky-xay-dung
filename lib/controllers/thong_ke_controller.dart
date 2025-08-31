import 'package:flutter/material.dart';
import '../services/thong_ke_service.dart';

class ThongKeController extends ChangeNotifier {
  final int? idCongTrinh;
  ThongKeController({this.idCongTrinh});
  int soLuongCongTrinh = 0;
  int soLuongNhatKy = 0;
  int soLuongNhanVien = 0;
  int soLuongNhanVienCongTrinh = 0;
  int soLuongDMThuChi = 0;
  int soLuongCoBan = 0;
  int soLuongUngLuong = 0;
  int soLuongCoMat = 0;
  int soLanThuChi = 0;
  int soLanUngLuong = 0;
  final _service = ThongKeService();

  // Load count lần đầu hoặc sau khi thay đổi dữ liệu
  Future<void> loadCounts() async {
    soLuongCongTrinh = await _service.getSoLuongCongTrinh();
    soLuongNhatKy = await _service.getSoLuongNhatKy(idCongTrinh);
    soLuongNhanVien = await _service.getSoLuongNhanVien();
    soLuongNhanVienCongTrinh = await _service.getSoLuongNhanVienCongTrinh(idCongTrinh);
    soLuongDMThuChi = await _service.getSoLuongDMThuChi();
    soLuongCoBan = await _service.getSoLuongCoBan();
    soLuongUngLuong = await _service.getSoLuongUngLuong();
    soLuongCoMat = await _service.getSoLuongCoMat(idCongTrinh);
    soLanThuChi = await _service.getSoLanThuChi(idCongTrinh);
    soLanUngLuong = await _service.getSoLuongUngLuong(idCongTrinh);
    notifyListeners(); // thông báo cho UI
  }

  // Nếu muốn cập nhật riêng lẻ từng count
  Future<void> updateSoLuongUngLuong() async {
    soLuongCongTrinh = await _service.getSoLuongUngLuong();
    notifyListeners();
  }
  Future<void> updateSoLuongCongTrinh() async {
    soLuongCongTrinh = await _service.getSoLuongCongTrinh();
    notifyListeners();
  }

  Future<void> updateSoLuongNhatKy() async {
    soLuongNhatKy = await _service.getSoLuongNhatKy();
    notifyListeners();
  }

  Future<void> updateSoLuongNhanVien() async {
    soLuongNhatKy = await _service.getSoLuongNhanVien();
    notifyListeners();
  }

  Future<void> updateSoLuongDMThuChi() async {
    soLuongNhatKy = await _service.getSoLuongDMThuChi();
    notifyListeners();
  }
  Future<void> updateSoLuongCoMat() async {
    soLuongNhatKy = await _service.getSoLuongCoMat(idCongTrinh);
    notifyListeners();
  }
  Future<void> updateSoLanThuChi() async {
    soLuongNhatKy = await _service.getSoLanThuChi(idCongTrinh);
    notifyListeners();
  }
  Future<void> updateSoLanUngLuong() async {
    soLuongNhatKy = await _service.getSoLuongUngLuong(idCongTrinh);
    notifyListeners();
  }
}
