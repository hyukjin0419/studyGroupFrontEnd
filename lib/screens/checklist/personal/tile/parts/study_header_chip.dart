import 'dart:developer';

import 'package:flutter/material.dart';

class StudyHeaderChip extends StatelessWidget {
  final String? name;
  final Color color;
  final VoidCallback onAddPressed;

  const StudyHeaderChip({
    super.key,
    this.name,
    required this.color,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: InkWell(
        onTap: (){
          // log("hello");
          onAddPressed();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name!,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.fromLTRB(0,0,0,2),
              child: Text('+',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}