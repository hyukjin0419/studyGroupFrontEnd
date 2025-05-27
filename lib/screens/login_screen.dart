import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/models/member.dart';
import 'package:study_group_front_end/providers/member_provider.dart';
import 'package:study_group_front_end/screens/study_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  String? _error;

  Future<void> _handleLogin() async {
    final memberProvider = context.read<MemberProvider>();

    try {
      await memberProvider.login(MemberLoginReqDto(
        userName: _idController.text.trim(),
        password: _pwController.text,
      ));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StudyListScreen()),
      );
      debugPrint("로그인 성공");
    }  catch(e) {
      setState(() {
        _error = "로그인 실패: 아이디 또는 비밀번호를 확인하세요.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("로그인")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(labelText: "아아디"),
            ),
            TextField(
              controller: _pwController,
              decoration: const InputDecoration(labelText: "비밀번호"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _handleLogin, child: Text("로그인")),
            if(_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ]
          ],
        )
      )
    );
  }
}