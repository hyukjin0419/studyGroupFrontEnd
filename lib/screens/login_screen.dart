import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/api_service/Auth/token_manager.dart';
import 'package:study_group_front_end/dto/member/login/member_login_request.dart';
import 'package:study_group_front_end/init_prefetch.dart';
import 'package:study_group_front_end/providers/me_provider.dart';
import 'package:study_group_front_end/snack_bar/show_error_snackbar.dart';
import 'package:study_group_front_end/util/color_converters.dart';

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
  final FocusNode _idFocus = FocusNode();
  final FocusNode _pwFocus = FocusNode();


  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
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
                        const SizedBox(height: 30),
                        Text(
                          'Sync Mate',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: hexToColor("0xFF1B325E"),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          '팀 프로젝트, 이제 실시간으로 체크하세요',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: hexToColor("0xFF1B325E"),
                          ),
                        ),
                        const SizedBox(height: 60),
                        SizedBox(
                          width: 285,
                          height: 40,
                          child: TextFormField(
                            focusNode: _idFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _pwFocus.requestFocus(),
                            style: Theme.of(context).textTheme.bodySmall,
                            decoration: InputDecoration(
                              hintText: '아이디',
                              hintStyle: Theme.of(context).textTheme.bodySmall,
                              filled: true,
                              fillColor: hexToColor("0xFFD9D9D9"),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              errorStyle: const TextStyle(height: 0),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical:10,
                                horizontal: 12,
                              ),
                            ),
                            onSaved: (val) => _userName = val?.trim() ?? '',
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return null;
                              }
                            }
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 285,
                          height: 40,
                          child: TextFormField(
                            focusNode: _pwFocus,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              _pwFocus.unfocus();
                            },
                            style: Theme.of(context).textTheme.bodySmall,
                            decoration: InputDecoration(
                              hintText: '비밀번호',
                              hintStyle: Theme.of(context).textTheme.bodySmall,
                              filled: true,
                              fillColor: hexToColor("0xFFD9D9D9"),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical:10,
                                horizontal: 12,
                              ),
                              errorStyle: const TextStyle(height: 0),
                            ),
                            obscureText: true,
                            onSaved: (val) => _password = val?.trim() ?? '',
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return null;
                                }
                              }
                          ),
                        ),
                        const SizedBox(height: 10),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : SizedBox(
                          width: 285,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: _submit,
                            child: const Text("로그인"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hexToColor('0xFF73B4E3'),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),

                        SizedBox(
                          width: 285,
                          height: 40,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //TODO: 아이디 찾기
                              TextButton(onPressed: () {}, child: const Text('아이디찾기')),
                              Text(' | ', style: Theme.of(context).textTheme.bodySmall),
                              //TODO: 비밀번호 찾기
                              TextButton(onPressed: () {}, child: const Text('비밀번호 찾기')),
                              const Spacer(),
                              TextButton(onPressed: () => context.go('/signup'), child: const Text('회원가입')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
          ),
        )
    );
  }

  Future<void> _submit() async {
    final currentForm = _formKey.currentState;
    if(currentForm == null){
      showBottomErrorSnackBar(context, "아이디 비밀번호가 입력되지 않았어요!");
    }

    if(!currentForm!.validate()) {
      showBottomErrorSnackBar(context, "아이디 비밀번호를 확인해주세요!");
      return;
    }
    currentForm.save();

    setState(() => _isLoading = true);

    try {
      final meProvider = context.read<MeProvider>();
      await meProvider.login(
        MemberLoginRequest(
          userName: _userName,
          password: _password,
          deviceToken: await TokenManager.getFcmToken(),
          deviceType: getDeviceType(),
        ),
      );

      await initIfLoggedIn(context);

      if (mounted) {
        context.go('/personal');
      }
    } catch (e) {
      String errorMessage = "로그인 실패";

      try {
        errorMessage = e.toString().replaceFirst("Exception: ", "");
      } catch (_) {
        errorMessage = e.toString();
      }

      print("error: $errorMessage");
      if(mounted) {
        showMiddleErrorSnackBar(
            context, "다시 확인해 주세요.", errorMessage);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

String getDeviceType() {
  if(kIsWeb) return "WEB";
  if(Platform.isAndroid) return "ANDROID";
  if(Platform.isIOS) return "IOS";
  if(Platform.isMacOS) return "MACOS";
  if(Platform.isWindows) return "WINDOWS";
  if(Platform.isLinux) return "LINUX";
  return "UNKOWN";
}