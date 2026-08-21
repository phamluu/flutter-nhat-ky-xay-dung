import 'package:flutter/material.dart';

Widget buildLoading() {
  return const Center(
    child: SizedBox(
      width: 32,
      height: 32,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
      ),
    ),
  );
}