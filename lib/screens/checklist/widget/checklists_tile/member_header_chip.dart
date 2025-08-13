import 'dart:developer';

import 'package:flutter/material.dart';

class MemberHeaderChip extends StatelessWidget {
  final String name;
  final Color color;
  final VoidCallback onAddPressed;
  
  const MemberHeaderChip({
    super.key,
    required this.name,
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
            Text(name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.fromLTRB(0,0,0,2),
              child: Text('+',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}