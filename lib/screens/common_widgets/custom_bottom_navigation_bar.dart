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
    return NavigationBar(
      height: 80, // 필요 시 고정
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
        NavigationDestination(icon: Icon(Icons.person), label: '개인'),
        NavigationDestination(icon: Icon(Icons.groups), label: '팀'),
        NavigationDestination(icon: Icon(Icons.calendar_today), label: '시간표'),
        NavigationDestination(icon: Icon(Icons.settings), label: '설정'),
      ],
    );
  }
}
