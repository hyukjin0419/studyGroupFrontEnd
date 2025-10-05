import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/member/signup/member_create_request.dart';
import 'package:study_group_front_end/providers/me_provider.dart';
import 'package:study_group_front_end/snack_bar/show_error_snackbar.dart';

class SignUpScreen extends StatefulWidget{
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String _userName = '';
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      await context.read<MeProvider>().create(
        MemberCreateRequest(userName: _userName, password: _password, email: _email),
      );

      if (mounted) context.go('/studies');
    } catch (e) {
      String errorMessage;

      try {
        errorMessage = e.toString().replaceFirst("Exception: ", "");
      } catch (_) {
        errorMessage = e.toString();
      }
      if(mounted){
        showBottomErrorSnackBar(context, errorMessage);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: '아이디'),
                onSaved: (val) => _userName = val!.trim(),
                validator: (val) =>
                (val == null || val.isEmpty) ? '아이디를 입력하세요' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: '이메일'),
                onSaved: (val) => _email = val!.trim(),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return '이메일을 입력하세요';
                  }

                  final emailRegex = RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                  );

                  if (!emailRegex.hasMatch(val)) {
                    return '올바른 이메일 형식이 아닙니다';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: '비밀번호'),
                obscureText: true,
                onSaved: (val) => _password = val!.trim(),
                validator: (val) =>
                (val == null || val.length < 6) ? '6자 이상 입력하세요' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _submit,
                child: const Text('회원가입'),
              ),
              TextButton(
                onPressed: () {
                  context.go('/login');
                },
                child: const Text('이미 계정이 있으신가요? 로그인하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
