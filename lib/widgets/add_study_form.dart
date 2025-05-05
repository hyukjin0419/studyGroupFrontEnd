import 'package:flutter/material.dart';

class AddStudyForm extends StatelessWidget {
  final TextEditingController titleController;

  const AddStudyForm({
    required this.titleController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: titleController,
          decoration: InputDecoration(labelText: '제목'),
        )
      ],
    );
  }
}