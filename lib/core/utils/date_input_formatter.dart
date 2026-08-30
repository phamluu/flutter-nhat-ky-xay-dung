import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    String cleanText = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (cleanText.length > 8) {
      cleanText = cleanText.substring(0, 8);
    }

    // Giới hạn NGÀY (2 số đầu): Tối đa là 31
    if (cleanText.length >= 2) {
      int day = int.tryParse(cleanText.substring(0, 2)) ?? 0;
      if (day > 31) {
        cleanText = '31${cleanText.substring(2)}';
      } else if (day == 0) {
        cleanText = '01${cleanText.substring(2)}';
      }
    }

    // Giới hạn THÁNG (số thứ 3 và 4): Tối đa là 12
    if (cleanText.length >= 4) {
      int month = int.tryParse(cleanText.substring(2, 4)) ?? 0;
      if (month > 12) {
        cleanText = '${cleanText.substring(0, 2)}12${cleanText.substring(4)}';
      } else if (month == 0) {
        cleanText = '${cleanText.substring(0, 2)}01${cleanText.substring(4)}';
      }
    }

    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < cleanText.length; i++) {
      buffer.write(cleanText[i]);
      if (i == 1 || i == 3) {
        buffer.write('/');
      }
    }

    final String formattedText = buffer.toString();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}