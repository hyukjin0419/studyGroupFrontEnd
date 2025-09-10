import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 80, // 필요 시 고정
      selectedIndex: selectedIndex,
      // onDestinationSelected: (index) {
      //   switch (index) {
      //     case 0:
      //       context.go('/me');
      //       break;
      //     case 1:
      //       context.go('/studies');
      //       break;
      //     case 2:
      //       context.go('/schedule');
      //       break;
      //     case 3:
      //       context.go('/settings');
      //       break;
      //   }
      // },

        destinations: const [
        NavigationDestination(icon: Icon(Icons.person), label: '개인'),
        NavigationDestination(icon: Icon(Icons.groups), label: '팀'),
        NavigationDestination(icon: Icon(Icons.calendar_today), label: '시간표'),
        NavigationDestination(icon: Icon(Icons.settings), label: '설정'),
      ],
    );
  }
}
