import 'package:flutter/material.dart';

class AddChecklistForm extends StatelessWidget {
  final TextEditingController controller;

  const AddChecklistForm({
    required this.controller,
    Key? key,
}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: '체크리스트 내용',
        border: OutlineInputBorder(),
      ),
    );
  }
}