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
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),

                  _buildChecklistItemModalFooter(onEditPressed: onEdit, onDeletePressed: onDelete),

                  const SizedBox(height: 20),
                ],
              ),
            ),
        );
      },
  );
}

Widget _buildChecklistItemModalFooter({
  required VoidCallback onEditPressed,
  required VoidCallback onDeletePressed,
}) {
  return Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(child: ActionButton(icon: Icons.edit, label: '수정', onTap: onEditPressed)),
        const SizedBox(width: 15),
        Expanded(child: ActionButton(icon: Icons.delete, label: '삭제', color: Colors.red, onTap: onDeletePressed)),
      ],
    ),
  );
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
    );
  }
}