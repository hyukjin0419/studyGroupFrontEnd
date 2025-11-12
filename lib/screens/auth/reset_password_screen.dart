import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/providers/me_provider.dart';
import 'package:study_group_front_end/snack_bar/show_error_snackbar.dart';
import 'package:study_group_front_end/util/color_converters.dart';
import 'package:study_group_front_end/util/errorExtractor.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  bool _isLoading = false;
  bool _isSent = false;
  String? _errorType;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Form(
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo/owl.png',
                    height: 200,
                  ),
                  const SizedBox(height: 20),
                  // Sync Mate 타이틀
                  Text(
                    'Sync Mate',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: hexToColor("0xFF1B325E"),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    '비밀번호 찾기',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: hexToColor("0xFF1B325E"),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '가입 시 등록한 이메일로\n비밀번호 재설정 링크를 발송해드립니다',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // 이메일 입력 필드
                  SizedBox(
                    width: 285,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 40,
                          child: TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _sendUsername(),
                            style: Theme.of(context).textTheme.bodySmall,
                            decoration: InputDecoration(
                              hintText: 'example@email.com',
                              hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[400],
                              ),
                              filled: true,
                              fillColor: hexToColor("0xFFD9D9D9"),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              // error: null,
                              // errorText: null,
                              // errorBorder: null,
                              // errorMaxLines: null,
                              // errorStyle: const TextStyle(height: 0),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 발송 버튼
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                    width: 285,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _sendUsername,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hexToColor('0xFF73B4E3'),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(_isSent ? '재발송' : '발송'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildStatusMessage(),
                  // const SizedBox(height: 10),
                  // 하단 링크
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text(
                          '로그인으로 돌아가기',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    if (_isSent) {
      return _buildInfoBox(
        icon: Icons.check_circle_outline,
        color: Colors.green,
        text: "이메일이 발송되었습니다.\n메일함을 확인해주세요.",
      );
    }

    if (_errorType == "empty") {
      return _buildInfoBox(
        icon: Icons.error_outline,
        color: Colors.orange,
        text: "이메일을 입력해주세요.",
      );
    }

    if (_errorType == "invalid") {
      return _buildInfoBox(
        icon: Icons.error_outline,
        color: Colors.red,
        text: "올바른 이메일 형식이 아닙니다.\n다시 입력해주세요.",
      );
    }

    if (_errorType == "server") {
      return _buildInfoBox(
        icon: Icons.error_outline,
        color: Colors.red,
        text: "이메일 발송 중 오류가 발생했습니다.",
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInfoBox({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        width: 285,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _sendUsername() async {
    final value = _emailController.text.trim();
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    setState((){
      _isSent = false;
      _errorType = null;
    });


    if (value.isEmpty) {
      setState(() => _errorType = "empty");
      return;
    }
    if (!emailRegExp.hasMatch(value)) {
      setState(() => _errorType = "invalid");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: 아이디 찾기 API 호출
      await context.read<MeProvider>().sendPasswordResetEmail(_emailController.text);

      // 임시로 2초 대기 (실제 API 호출 시뮬레이션)
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isSent = true;
          _errorType = null;
        });

      }
    } catch (e) {
      final errorMessage = extractErrorMessageFromMessage(e);

      if (mounted) {
        showBottomErrorSnackBar(context, errorMessage);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}