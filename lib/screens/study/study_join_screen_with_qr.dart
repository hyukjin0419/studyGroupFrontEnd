import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/study_member/fellower/study_join_request.dart';
import 'package:study_group_front_end/providers/study_join_provider.dart';

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
                hintText: "참여코드 12자리를 입력해주세요.",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: (){
                    ///TODO: QR 스캔 기능 연결
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

  void _submitJoinCode() async {
    final code = _codeController.text.trim();

    if(code.length != 12){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("참여코드는 12자리여야 합니다.")),
      );
      return;
    }

    try {
      await context.read<StudyJoinProvider>().join(StudyJoinRequest(joinCode: code));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("스터디에 참여했습니다.")),
        );
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("참여 실패: $e")),
      );
    }
  }
}