import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top:0),
      child: NavigationBar(
        height: 75,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // 둥근 정도 줄이기
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/personal');
              break;
            case 1:
              context.go('/studies');
              break;
            case 2:
              context.go('/studies');
              break;
            case 3:
              context.go('/settings');
              break;
          }
        },

          destinations: const [
          NavigationDestination(icon: Icon(Icons.person_3_outlined), label: '개인'),
          NavigationDestination(icon: Icon(Icons.workspaces_outline), label: '팀'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), label: '알림'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: '설정'),
        ],
      ),
    );
  }
}
