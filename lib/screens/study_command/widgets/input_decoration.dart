import 'package:flutter/material.dart';
import 'package:study_group_front_end/util/color_converters.dart';

InputDecoration fieldDecoration(
BuildContext context, {
  required String label,
  Widget? suffix,
}) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: hexToColor("0xFFF7F8FA"),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    suffixIcon: suffix == null ? null : Padding(
      padding: const EdgeInsets.only(right: 6),
      child: suffix,
    ),
  );
}