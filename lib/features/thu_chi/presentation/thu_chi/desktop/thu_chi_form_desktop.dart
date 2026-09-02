import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';
import 'package:nhat_ky_xay_dung/features/cong_trinh/data/models/CongTrinh.dart';
import '../../../../../core/utils/currencyFormat.dart';
import '../../../../cong_trinh/data/respositories/CongTrinhReponsitory.dart';
import '../../../data/models/DanhMucThuChi.dart';
import '../../../data/models/ThuChi.dart';
import '../../../data/services/danh_muc_thu_chi_service.dart';
import '../../../data/services/thu_chi_service.dart';
// Import file chứa TableHeader, HangHoaInput, tableCell, tableInputDecoration
import '../widgets/_sectionTitle.dart';
import '../widgets/_tableForm.dart';

class ThuChiFormDesktop extends StatefulWidget {
  final ThuChi? thuChi;
  final int? idCongTrinh;

  const ThuChiFormDesktop({
    super.key,
    this.thuChi,
    this.idCongTrinh,
  });

  @override
  State<ThuChiFormDesktop> createState() => _ThuChiFormDesktopState();
}

class _ThuChiFormDesktopState extends State<ThuChiFormDesktop> {
  final _formKey = GlobalKey<FormState>();
  final _soTienController = TextEditingController();
  final _ghiChuController = TextEditingController();
  final _ngayController = TextEditingController();
  final _thuChiService = ThuChiService();
  final _dmService = DanhMucThuChiService();
  final _ctService = CongtrinhReponsitory();
  final _dateFormat = DateFormat("dd/MM/yyyy");

  // State cho bảng hàng hóa
  final List<HangHoaInput> _hangHoaList = [];
  final TextEditingController _soDongController = TextEditingController(text: '1');

  int _loai = 0;
  List<DanhMucThuChi> _danhMucs = [];
  int? _selectedDanhMucId;

  List<CongTrinh> _conTrinhs = [];
  int? _selectedCongTrinhId;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initData();
    _themHangHoa(1); // Mặc định tạo 1 dòng ban đầu
  }

  @override
  void dispose() {
    _soTienController.dispose();
    _ghiChuController.dispose();
    _ngayController.dispose();
    _soDongController.dispose();
    for (var item in _hangHoaList) {
      item.dispose();
    }
    super.dispose();
  }

  // ============================================================
  // XỬ LÝ THÊM / XÓA DÒNG HÀNG HÓA
  // ============================================================

  void _themHangHoa([int? count]) {
    final soDong = count ?? int.tryParse(_soDongController.text) ?? 1;
    setState(() {
      for (int i = 0; i < soDong; i++) {
        final item = HangHoaInput();
        item.soLuongController.addListener(_onItemChange);
        item.donGiaController.addListener(_onItemChange);
        _hangHoaList.add(item);
      }
    });
  }

  void _onItemChange() {
    setState(() {}); // Rebuild để tính lại Thành tiền
  }

  void _xoaHangHoa(int index) {
    setState(() {
      _hangHoaList[index].dispose();
      _hangHoaList.removeAt(index);
    });
  }

  Future<void> _initData() async {
    try {
      final dms = await _dmService.getAll();
      final cts = await _ctService.getDanhSachCongTrinh();
      if (!mounted) return;
      setState(() {
        _danhMucs = dms;
        _conTrinhs = cts;
        if (widget.thuChi != null) {
          // ==========================================
          // TRƯỜNG HỢP SỬA: LOAD DỮ LIỆU CŨ VÀO DÒNG HÀNG HÓA
          // ==========================================
          final tc = widget.thuChi!;
          // Khởi tạo 1 dòng HangHoaInput với dữ liệu có sẵn
          final item = HangHoaInput(
            ten: tc.tenHangHoa ?? '', // Hoặc tên hàng hóa tương ứng từ DB của bạn
            donVi: tc.donViTinh ?? '',            // Đơn vị (nếu DB có lưu)
            soLuong: tc.soLuong.toString(),         // Số lượng mặc định hoặc từ DB
            donGia: tc.donGia != null ? tc.donGia.toString() : '0',
          );

          // Lắng nghe sự thay đổi để tính lại thành tiền
          item.soLuongController.addListener(_onItemChange);
          item.donGiaController.addListener(_onItemChange);
          if (widget.thuChi!.donGia != null) {
            item.donGiaController.text =formatCurrency(widget.thuChi!.donGia!);
          }
          _hangHoaList.clear();
          _hangHoaList.add(item);

          // Nạp thông tin chung
          _soTienController.text = tc.donGia != null ? formatCurrency(tc.donGia!) : '';
          _ghiChuController.text = tc.ghiChu ?? '';
          try {
            _ngayController.text = _dateFormat.format(DateTime.parse(tc.ngay));
          } catch (_) {
            _ngayController.text = _dateFormat.format(DateTime.now());
          }
          _loai = tc.loai;
          _selectedDanhMucId = tc.idDanhMucThuChi;
          _selectedCongTrinhId = tc.idCongTrinh;

        } else {
          // ==========================================
          // TRƯỜNG HỢP THÊM MỚI: TẠO 1 DÒNG TRỐNG
          // ==========================================
          _selectedCongTrinhId = widget.idCongTrinh;
          _ngayController.text = _dateFormat.format(DateTime.now());
          if (_danhMucs.isNotEmpty) {
            _selectedDanhMucId = _danhMucs.first.id;
          }

          _hangHoaList.clear();
          _themHangHoa(1);
        }

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      showErrorToast(context, e, 'Không thể tải dữ liệu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.thuChi != null;
    return Container(
      color: const Color(0xfff5f6f8),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(isEdit),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildForm(isEdit),
            ),
          ],
        ),
      ),
    );
  }

  void _goBack() {
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    DateTime initial;
    try {
      final parts = _ngayController.text.split('/');
      initial = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (_) {
      initial = now;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('vi', 'VN'),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _ngayController.text = _dateFormat.format(picked);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Parse ngày giao dịch
    final dateParts = _ngayController.text.split('/');
    final tcDate = DateTime(
      int.parse(dateParts[2]),
      int.parse(dateParts[1]),
      int.parse(dateParts[0]),
    );
    setState(() {
      _isSaving = true;
    });
    try {
      if (widget.thuChi != null) {
        // ==========================================
        // TRƯỜNG HỢP SỬA: CẬP NHẬT 1 BẢN GHI DUY NHẤT
        // ==========================================
        final item = _hangHoaList.isNotEmpty ? _hangHoaList.first : HangHoaInput();
        final tc = ThuChi(
          id: widget.thuChi!.id,
          idDanhMucThuChi: _selectedDanhMucId,
          loai: _loai,
          donGia: item.donGia,
          tenHangHoa: item.tenController.text.trim(),
          donViTinh: item.donVi,
          soLuong: item.soLuong,
          ngay: tcDate.toIso8601String(),
          idCongTrinh: _selectedCongTrinhId,
          ngayTao: widget.thuChi!.ngayTao,
        );

        await _thuChiService.update(tc);

      } else {
        // ==========================================
        // TRƯỜNG HỢP THÊM MỚI: LƯU TẤT CẢ CÁC DÒNG ĐÃ NHẬP
        // ==========================================
        // Lọc bỏ những dòng hoàn toàn trống (không nhập tên và không nhập đơn giá/số lượng)
        final validItems = _hangHoaList.where((item) {
          return item.tenController.text.trim().isNotEmpty || item.donGia > 0 || item.soLuong > 0;
        }).toList();

        if (validItems.isEmpty) {
          throw 'Vui lòng nhập thông tin ít nhất 1 hàng hóa';
        }

        // Tạo danh sách object ThuChi từ validItems
        final listThuChi = validItems.map((item) {
          return ThuChi(
            idDanhMucThuChi: _selectedDanhMucId,
            loai: _loai,
            donGia: item.donGia,
            tenHangHoa: item.tenController.text.trim().isEmpty? null: item.tenController.text.trim(),
            donViTinh: item.donViController.text.trim().isEmpty? null: item.donViController.text.trim(),
            soLuong: item.soLuong,
            ngay: tcDate.toIso8601String(),
            idCongTrinh: _selectedCongTrinhId,
            ngayTao: DateTime.now().toIso8601String(),
          );
        }).toList();

// Gọi insert 1 lần duy nhất
        await _thuChiService.insertAll(listThuChi);
      }

      if (!mounted) return;
      showSuccessToast(
        context,
        widget.thuChi == null ? "Thêm mới thành công" : "Cập nhật thành công",
      );
      Navigator.pop(context, true);

    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });
      showErrorToast(context, e, 'Lưu khoản thu chi thất bại: $e');
    }
  }

  Future<void> _delete() async {
    if (widget.thuChi?.id == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa khoản thu/chi?'),
        content: const Text('Bạn chắc chắn muốn xóa khoản này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await _thuChiService.delete(widget.thuChi!.id!);
      if (!mounted) return;
      showSuccessToast(context, "Xóa khoản thu/chi thành công");
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, e, 'Không thể xóa: $e');
    }
  }

  Widget _buildHeader(bool isEdit) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Sửa khoản thu chi' : 'Thêm khoản thu chi',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff263238),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.idCongTrinh != null
                    ? 'Khoản thu chi của công trình'
                    : 'Nhập thông tin khoản thu hoặc chi',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),
        IconButton(
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back),
          iconSize: 21,
          tooltip: 'Quay lại',
          style: IconButton.styleFrom(
            fixedSize: const Size(42, 42),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _loai == 1
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isEdit ? Icons.edit_outlined : Icons.receipt_long_outlined,
            color: _loai == 1 ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: _isSaving
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Icon(Icons.save_outlined, size: 19),
          label: Text(_isSaving ? 'Đang lưu...' : 'Lưu'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(bool isEdit) {
    return Center(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 30),
          children: [
            _buildMainCard(),
            const SizedBox(height: 16),
            _buildNoteCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Thông tin khoản thu chi',
          ),
          const SizedBox(height: 20),
          const Text(
            'Loại giao dịch',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _typeButton(
                  value: 0,
                  title: 'Khoản chi',
                  icon: Icons.arrow_upward,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _typeButton(
                  value: 1,
                  title: 'Khoản thu',
                  icon: Icons.arrow_downward,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildDanhMucField()),
              const SizedBox(width: 16),
              Expanded(child: _buildCongTrinhField()),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 420,
            child: TextFormField(
              controller: _ngayController,
              readOnly: true,
              onTap: _pickDate,
              decoration: _inputDecoration(
                label: 'Ngày giao dịch',
                icon: Icons.event_outlined,
                suffix: const Icon(Icons.calendar_today_outlined, size: 19),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng chọn ngày';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeButton({
    required int value,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    final selected = _loai == value;
    return InkWell(
      onTap: () {
        setState(() {
          _loai = value;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: selected
                    ? color.withOpacity(0.15)
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: selected ? color : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? color : Colors.grey.shade700,
              ),
            ),
            const Spacer(),
            if (selected) Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDanhMucField() {
    return DropdownButtonFormField<int?>(
      value: _danhMucs.any((dm) => dm.id == _selectedDanhMucId)
          ? _selectedDanhMucId
          : null,
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text('Không chọn danh mục'),
        ),
        ..._danhMucs.map(
              (dm) => DropdownMenuItem<int?>(
            value: dm.id,
            child: Text(dm.ten),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedDanhMucId = value;
        });
      },
      decoration: _inputDecoration(
        label: 'Danh mục',
        icon: Icons.category_outlined,
      ),
    );
  }

  Widget _buildCongTrinhField() {
    final disabled = widget.idCongTrinh != null;

    return DropdownButtonFormField<int?>(
      value: _conTrinhs.any((ct) => ct.id == _selectedCongTrinhId)
          ? _selectedCongTrinhId
          : null,
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text('Chọn công trình'),
        ),
        ..._conTrinhs.map(
              (ct) => DropdownMenuItem<int?>(
            value: ct.id,
            child: Text(
              ct.ten,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: disabled
          ? null
          : (value) {
        setState(() {
          _selectedCongTrinhId = value;
        });
      },
      decoration: _inputDecoration(
        label: 'Công trình',
        icon: Icons.business_outlined,
      ),
    );
  }

  Widget _buildNoteCard() {
    final isEdit = widget.thuChi != null;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              sectionTitle(
                icon: Icons.inventory_2_outlined,
                title: 'Chi tiết hàng hóa',
              ),
              // Chỉ cho phép nhập thêm nhiều dòng khi THÊM MỚI
              if (!isEdit)
                Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: TextFormField(
                        controller: _soDongController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: tableInputDecoration(hintText: 'Số dòng'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _themHangHoa(),
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm dòng'),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 18),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.2),
              3: FlexColumnWidth(1.8),
              4: FlexColumnWidth(1.8),
              5: FixedColumnWidth(48),
            },
            border: TableBorder.all(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade100),
                children: [
                  const TableHeader('Tên hàng hóa'),
                  const TableHeader('Đơn vị'),
                  const TableHeader('Số lượng'),
                  const TableHeader('Đơn giá'),
                  const TableHeader('Thành tiền'),
                  // Nếu đang Sửa thì ẩn cột nút Xóa dòng
                  if (!isEdit) const TableHeader('') else const TableHeader(''),
                ],
              ),
              ..._hangHoaList.asMap().entries.map((entry) {
                int index = entry.key;
                HangHoaInput item = entry.value;

                return TableRow(
                  children: [
                    tableCell(
                      TextFormField(
                        controller: item.tenController,
                        decoration: tableInputDecoration(hintText: 'Tên hàng hóa'),
                      ),
                    ),
                    tableCell(
                      TextFormField(
                        controller: item.donViController,
                        decoration: tableInputDecoration(hintText: 'Cái'),
                      ),
                    ),
                    tableCell(
                      TextFormField(
                        controller: item.soLuongController,
                        keyboardType: TextInputType.number,
                        decoration: tableInputDecoration(hintText: '0'),
                      ),
                    ),
                    tableCell(
                      TextFormField(
                        controller: item.donGiaController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        decoration: tableInputDecoration(hintText: '0'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nhập số tiền';
                          }
                          final amount = parseCurrency(value, );
                          if (amount <= 0) {
                            return 'Số tiền phải lớn hơn 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    tableCell(
                      Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          formatCurrency(item.thanhTien),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    tableCell(
                      // Khi chỉnh sửa thì không cho phép xóa dòng duy nhất này
                      isEdit
                          ? const SizedBox()
                          : IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => _xoaHangHoa(index),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xfffafafa),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blue.shade600, width: 1.5),
      ),
    );
  }
}