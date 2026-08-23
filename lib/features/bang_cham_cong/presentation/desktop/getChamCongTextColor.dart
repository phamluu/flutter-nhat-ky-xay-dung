import 'dart:ui';

import 'package:flutter/material.dart';

Color getChamCongTextColor(
    String value,
    )
{
  if (value.isEmpty) {
    return Colors.grey;
  }

  switch (value.toUpperCase())
  {
    case "X":
      return Colors.green.shade700;

    case "P":
      return Colors.orange.shade800;

    case "CT":
      return Colors.blue.shade700;

    case "L":
      return Colors.red.shade700;

    case "O":
      return Colors.purple.shade700;

    default:
      return Colors.grey.shade700;
  }
}