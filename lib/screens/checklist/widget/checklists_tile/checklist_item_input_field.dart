import 'package:flutter/material.dart';
import 'package:study_group_front_end/screens/checklist/widget/checklists_tile/customized_check_box.dart';

class ChecklistItemInputField extends StatelessWidget {
  final Color color;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onDone; //final void Function() onDone;
  final void Function(String) onSubmitted;

  const ChecklistItemInputField({
    super.key,
    required this.color,
    required this.controller,
    required this.focusNode,
    required this.onDone,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context){
    return Container(
      height: 45,//?
      padding: const EdgeInsets.fromLTRB(10,0,12,0),
      child: Row(
        children: [
          CustomizedCheckBox(
              color: color,
              completed: null
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              cursorHeight: 15,
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              style: Theme.of(context).textTheme.titleMedium,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.only(bottom: 3),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: color),
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isEmpty) return;
                onSubmitted(value.trim());
                onDone();
              },
            )
          ),
          const SizedBox(width: 12),
          const Icon(Icons.more_horiz),
        ],
      ),
    );
  }
}