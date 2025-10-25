import 'package:flutter/material.dart';
import 'package:study_group_front_end/util/color_converters.dart';

class CustomizedCheckBox extends StatelessWidget {
  final Color color;
  final bool? completed;

  const CustomizedCheckBox({
    super.key,
    required this.completed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        /*
        if (completed == null) return false; else return complete
        if (completed) return color; else return hexToColor("0xFFD9D9D9"),
         */
        color: (completed ?? false) ? color : hexToColor("0xFFD9D9D9"),
      ),
      child: (completed ?? false) ? const Icon(
        Icons.check,
        size: 20,
        color: Colors.white,
      ) : null,
    );
  }
}