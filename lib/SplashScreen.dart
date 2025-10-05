import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/providers/me_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
/*
여기서 개인 체크리스트 + 스터디 리스트를 불러와야 함.
 */
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final meProvider = context.read<MeProvider>();
    final isLoggedIn = await meProvider.loadCurrentMember();

    if (mounted) {
      if (isLoggedIn) {
        context.go('/personal'); // 로그인 되어 있으면 홈으로
      } else {
        context.go('/login'); // 없으면 로그인 화면으로
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
