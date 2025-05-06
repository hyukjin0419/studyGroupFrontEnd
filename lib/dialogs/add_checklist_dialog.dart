import 'package:flutter/material.dart';
import '../widgets/add_checklist_form.dart';

void showAddChecklistDialog(
  BuildContext context,
  void Function (String content) onSubmit,
) {
  final controller = TextEditingController();

  showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("새 체크리스트 항목"),
        content: AddChecklistForm(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("취소"),
          ),
          TextButton(
            onPressed: () {
              final content = controller.text.trim();
              if (content.isNotEmpty){
                onSubmit(content);
                Navigator.pop(context);
              }
            },
            child:Text("추가"),
          ),
          ],
      ),
  );
}