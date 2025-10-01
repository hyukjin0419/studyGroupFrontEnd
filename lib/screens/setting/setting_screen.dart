import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/providers/me_provider.dart';
import 'package:go_router/go_router.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("설정")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await context.read<MeProvider>().logout();
            if (context.mounted) {
              context.go('/login');
            }
          },
          child: const Text("로그아웃"),
        ),
      ),
    );
  }
}
