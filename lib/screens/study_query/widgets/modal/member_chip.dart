import 'package:flutter/material.dart';

class MemberChip extends StatelessWidget {
  final String name;
  final Color color;
  final VoidCallback onAddPressed;

  const MemberChip({
    super.key,
    required this.name,
    required this.color,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 20,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      child: InkWell(
        onTap: (){
          // log("hello");
          onAddPressed();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}