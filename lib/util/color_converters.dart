import 'package:flutter/material.dart';

//0xFF이거 추가하는 걸로 리펙토링 하자! -> No 저장 자체가 이렇게 되어야 함
Color hexToColor(String hexString) {
  return Color(int.parse(hexString));
}

String colorToHex(Color color) {
  return '0x${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
}
