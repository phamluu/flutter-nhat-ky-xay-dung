import 'dart:ui';

import 'package:flutter/material.dart';

Color getChamCongColor(
    String value,
    ) {
  if (value.isEmpty) {
    return Colors.transparent;
  }

  switch (value.toUpperCase()) {
    case "X":
      return Colors.green.withOpacity(.12);

    case "P":
      return Colors.orange.withOpacity(.14);

    case "CT":
      return Colors.blue.withOpacity(.12);

    case "L":
      return Colors.red.withOpacity(.10);

    case "O":
      return Colors.purple.withOpacity(.10);

    default:
      return Colors.grey.withOpacity(.10);
  }
}