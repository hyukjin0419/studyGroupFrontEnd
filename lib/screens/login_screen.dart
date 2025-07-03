import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/member/login/member_login_request.dart';
import 'package:study_group_front_end/providers/me_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _userName = '';
  String _password = '';
  bool _isLoading = false;

  Future<void> _submit() async {
    final currentForm = _formKey.currentState;
    if(currentForm == null || !currentForm.validate()) return;
    currentForm.save();

    setState(() => _isLoading = true);

    try {
      final meProvider = context.read<MeProvider>();
      await meProvider.login(
        MemberLoginRequest(userName: _userName, password: _password),
      );

      if (mounted) {
        context.go('/studies');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("로그인 실패: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('로그인')),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: "아이디"),
                    onSaved: (val) => _userName = val?.trim() ?? '',
                    validator: (val) =>
                    (val == null || val.isEmpty)
                        ? '아이디를 입력하세요'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "비밀번호"),
                    obscureText: true,
                    onSaved: (val) => _password = val?.trim() ?? '',
                    validator: (val) =>
                    (val == null || val.isEmpty)
                        ? '비밀번호를 입력하세요'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                      onPressed: _submit, child: const Text("로그인")),
                  TextButton(
                    onPressed: () => context.go('/signup'),
                    child: const Text('회원가입'),
                  ),
                ],
              ),
            )
        )
    );
  }
}
