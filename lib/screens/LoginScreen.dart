import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final dto = MemberLoginRequest(
      userName: _userNameController.text.trim(),
      password: _passwordController.text,
    );

    final success = await AuthApiService().login(dto);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home'); // 홈화면 라우트
      }
    } else {
      setState(() {
        _errorMessage = '로그인에 실패했습니다. 다시 시도해주세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(labelText: '아이디'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호'),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _login,
              child: const Text('로그인'),
            ),
          ],
        ),
      ),
    );
  }
}
