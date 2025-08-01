import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/study_member/fellower/study_join_request.dart';
import 'package:study_group_front_end/providers/study_join_provider.dart';
import 'package:study_group_front_end/providers/study_provider.dart';
import 'package:study_group_front_end/util/qr_scanner.dart';

class StudyJoinScreenWithQr extends StatefulWidget {
  const StudyJoinScreenWithQr({super.key});

  @override
  State<StudyJoinScreenWithQr> createState() => _StudyJoinScreenWithQrState();
}

class _StudyJoinScreenWithQrState extends State<StudyJoinScreenWithQr>{
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("팀 참여하기"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                hintText: "참여코드를 입력해주세요.",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: (){
                    _scanAndFillCode();
                  },
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                  onPressed: _submitJoinCode,
                  child: const Text("확인"),
              ),
            ),
          ],
        ),
      )
    );
  }

  void _scanAndFillCode() async {
    final code = await scanQrCode(context);
    if (code != null) {
      setState(() {
        _codeController.text = code;
      });
    }
  }

  void _submitJoinCode() async {
    final code = _codeController.text.trim();

    try {
      await context.read<StudyJoinProvider>().join(StudyJoinRequest(joinCode: code));
      if (!mounted) return;
      await context.read<StudyProvider>().getMyStudies();
      if (!mounted) return;


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("스터디에 참여했습니다.")),
      );

      context.go('/studies');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("참여 실패: $e")),
      );
    }
  }
}