import 'package:flutter/material.dart';
import 'package:study_group_front_end/dto/study/create/study_create_request.dart';
import 'package:study_group_front_end/service/study_api_service.dart';

class CreateStudyDialog extends StatefulWidget {
  const CreateStudyDialog({super.key});

  @override
  State<CreateStudyDialog> createState() => _CreatedStudyDialogState();
}

class _CreatedStudyDialogState extends State<CreateStudyDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _colorController = TextEditingController(text: "0xFF8AB4F8");

  bool _isLoading = false;

  void _createStudy() async {
    setState(() => _isLoading = true);

    try {
      final request = StudyCreateRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        color: _colorController.text.trim(),
      );

      final created = await StudyApiService().createStudy(request);

      if (context.mounted) Navigator.pop(context, created);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("스터디 생성 실패: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("스터디 생성"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: "이름")),
          TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: "설명")),
          TextField(controller: _colorController, decoration: const InputDecoration(labelText: "색상")),
        ],
      ),
      actions: [
        TextButton(onPressed: _isLoading ? null : () => Navigator.pop(context), child: const Text("취소")),
        ElevatedButton(
          onPressed: _isLoading ? null : _createStudy,
          child: _isLoading ? const CircularProgressIndicator() : const Text("생성"),
        ),
      ],
    );
  }
}
