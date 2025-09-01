import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/study/update/study_update_request.dart';
import 'package:study_group_front_end/providers/study_provider.dart';

class UpdateStudyDialog extends StatefulWidget {
  // final int studyId;
  final StudyUpdateRequest initialData;

  const UpdateStudyDialog({
    super.key,
    // required this.studyId,
    required this.initialData,
  });

  @override
  State<UpdateStudyDialog> createState() => _UpdateStudyDialogState();
}

class _UpdateStudyDialogState extends State<UpdateStudyDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _colorController;
  late final TextEditingController _dDayController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData.name);
    _descriptionController = TextEditingController(text: widget.initialData.description);
    _colorController = TextEditingController(text: widget.initialData.personalColor);

    final dueDate = widget.initialData.dueDate;
    final remainingDays = dueDate?.difference(DateTime.now()).inDays.clamp(1, 999);
    _dDayController = TextEditingController(text: remainingDays.toString());
  }

  void _updateStudy() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final personalColor = _colorController.text.trim();
    final dueDays = int.tryParse(_dDayController.text.trim());

    if (name.isEmpty || description.isEmpty || dueDays == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 필드를 올바르게 입력해주세요.")),
      );
      return;
    }

    final dueDate = DateTime.now().add(Duration(days: dueDays));
    final request = StudyUpdateRequest(
      studyId: widget.initialData.studyId,
      name: name,
      description: description,
      personalColor: personalColor,
      dueDate: dueDate,
    );

    setState(() => _isLoading = true);

    try {
      final provider = context.read<StudyProvider>();
      await provider.updateStudy(request);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("스터디 수정 실패: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("스터디 수정"),
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
          onPressed: _isLoading ? null : _updateStudy,
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("수정"),
        ),
      ],
    );
  }
}
