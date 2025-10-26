import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/providers/me_provider.dart';
import 'package:study_group_front_end/screens/common_dialog/confirmationDialog.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isAlarmEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '설정 화면',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // 상단 정보 카드
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '좋은 오후예요 ✨ 10월 25일 토요일',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '설정 관리',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '앱 설정을 관리하세요',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildListItem(
                  isChecked: isAlarmEnabled,
                  title: '알람 설정',
                  onTap: () => setState(() => isAlarmEnabled = !isAlarmEnabled),
                ),

                const SizedBox(height: 24),
                const Text(
                  '이용안내',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                _buildListItem(
                  isChecked: false,
                  title: '개인정보 처리방침',
                  showChevron: true,
                  onTap: () => _launchUrl('https://handsomely-nemophila-3e9.notion.site/Privacy-Policy-2977860e86188089a9f8e4c99395dafa?source=copy_link'),
                ),
                _buildListItem(
                  isChecked: false,
                  title: '서비스 이용약관',
                  showChevron: true,
                  onTap: () => _launchUrl('https://handsomely-nemophila-3e9.notion.site/Terms-of-Service-2977860e861880608d2dddf7d6691297?source=copy_link'),
                ),

                const SizedBox(height: 24),
                const Text('계정',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                _buildListItem(
                  isChecked: false,
                  title: '비밀번호 변경하기',
                  showChevron: true,
                  onTap: () {},
                ),
                _buildListItem(
                  isChecked: false,
                  title: '이메일 변경하기',
                  showChevron: true,
                  onTap: () {},
                ),
                _buildListItem(
                  isChecked: false,
                  title: '로그아웃',
                  showChevron: true,
                  titleColor: Colors.orange,
                  onTap: () async {
                    _logoutConfirmDialog(context, Colors.teal);
                  },
                ),
                _buildListItem(
                  isChecked: false,
                  title: '탈퇴하기',
                  showChevron: true,
                  titleColor: Colors.red,
                  onTap: () async {
                    _withdrawConfirmDialog(context, Colors.teal);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem({
    required bool isChecked,
    required String title,
    bool showChevron = false,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              if (!showChevron)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isChecked ? const Color(0xFF00BFA5) : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isChecked ? const Color(0xFF00BFA5) : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
                      : null,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    color: titleColor ?? Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if(!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception("해당 링크를 열 수 없습니다: $url");
    }
  }
}

Future<void> _logoutConfirmDialog(BuildContext context, Color color) async {
  final confirmed = await showConfirmationDialog(
      context: context,
      title: "로그아웃",
      description: "로그아웃 하시겠어요? \n로그인 화면으로 이동합니다!",
      confirmColor: color,
  );

  log("confimed value = $confirmed");

  if (confirmed == true) {
    await context.read<MeProvider>().logout();
    if (context.mounted) {
      context.go('/login');
    }
  }
}

Future<void> _withdrawConfirmDialog(BuildContext context, Color color) async {
  final confirmed = await showConfirmationDialog(
    context: context,
    title: "회원 탈퇴",
    description: "회원 탈퇴 후 개인정보를 포함한\n 데이터가 삭제되며 복구할 수 없습니다.\n정말 삭제하시겠습니까?",
    confirmColor: color,
  );

  log("confimed value = $confirmed");

  if (confirmed == true) {
    //TODO 탈퇴 api 호출
    // await context.read<MeProvider>().logout();
    if (context.mounted) {
      context.go('/login');
    }
  }
}