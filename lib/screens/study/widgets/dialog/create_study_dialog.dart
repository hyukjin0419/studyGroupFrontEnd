import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/study/create/study_create_request.dart';
import 'package:study_group_front_end/providers/study_provider.dart';

class CreateStudyDialog extends StatefulWidget {
  const CreateStudyDialog({super.key});

  @override
  State<CreateStudyDialog> createState() => _CreateStudyDialogState();
}

class _CreateStudyDialogState extends State<CreateStudyDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _colorController = TextEditingController(text: "0xFF8AB4F8");
  final _dDayController = TextEditingController(text: "30"); // 디폴트: 30일 뒤

  bool _isLoading = false;

  void _createStudy() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final color = _colorController.text.trim();
    final dueDays = int.tryParse(_dDayController.text.trim());

    if (name.isEmpty || description.isEmpty || dueDays == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 필드를 올바르게 입력해주세요.")),
      );
      return;
    }

    final dueDate = DateTime.now().add(Duration(days: dueDays));

    final request = StudyCreateRequest(
      name: name,
      color: color,
      dueDate: dueDate,
    );

    setState(() => _isLoading = true);

    try {
      final provider = context.read<StudyProvider>();
      await provider.createStudy(request);

      if (mounted) Navigator.pop(context);
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
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "이름")),
            TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: "설명")),
            TextField(controller: _colorController, decoration: const InputDecoration(labelText: "색상 (예: 0xFF8AB4F8)")),
            TextField(
              controller: _dDayController,
              decoration: const InputDecoration(labelText: "며칠 뒤 마감일? (예: 30)"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text("취소"),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createStudy,
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("생성"),
        ),
      ],
    );
  }
}
