import 'package:flutter/material.dart';
import 'package:study_group_front_end/util/color_converters.dart';

Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String description,
  String cancelText = '취소',
  String confirmText = '확인',
  Color confirmColor = Colors.red,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: hexToColor("0xFFF7F8FA"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 22),
        ),
      ),
      content: Text(
        description,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(15, 0, 15, 24),
      actions: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(
                  '취소',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: confirmColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(
                  '확인',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
