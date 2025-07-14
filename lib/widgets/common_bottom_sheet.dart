import 'package:flutter/material.dart';

class BottomSheetItem {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color iconColor;
  final Color textColor;

  BottomSheetItem({
    required this.icon,
    required this.text,
    required this.onTap,
    this.iconColor = Colors.black,
    this.textColor = Colors.black,
  });
}

void showCommonBottomSheet(BuildContext context, List<BottomSheetItem> items) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...items.map((item) => ListTile(
              leading: Icon(item.icon, color: item.iconColor),
              title: Text(item.text, style: TextStyle(color: item.textColor)),
              onTap: () {
                Navigator.pop(context);
                item.onTap();
              },
            )),
          ],
        )
      )
  );
}