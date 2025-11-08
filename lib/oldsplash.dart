import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_group_front_end/init_prefetch.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final isLoggedIn = await initIfLoggedIn(context);

    if (!mounted) return;

    if (isLoggedIn) {
      context.go('/personal');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}