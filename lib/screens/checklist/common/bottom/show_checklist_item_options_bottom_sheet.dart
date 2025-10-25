import 'package:flutter/material.dart';
import 'package:study_group_front_end/util/color_converters.dart';
import 'package:study_group_front_end/widgets/ios_handle_bar.dart';

void showChecklistItemOptionsBottomSheet({
  required BuildContext context,
  required String title,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: hexToColor("0xFFF7F8FA"),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  iosHandleBar(),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ActionButton(
                        icon: Icons.edit,
                        label: '수정',
                        width: 174,
                        onTap:() {
                          onEdit();
                        }
                      ),
                      ActionButton(
                        icon: Icons.delete,
                        label: '삭제',
                        color: Colors.red,
                          width: 174,
                        onTap:() {
                          onDelete();
                        }
                      ),
                    ],
                  ),
                ],
              ),
            ),
        );
      },
  );
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final double? width;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: width ?? double.infinity,
            height: 86,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(icon, color: color ?? Colors.black),
                const SizedBox(height: 8),
                Text(label, style: TextStyle(color: color ?? Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}