// screens/checklist/personal/widgets/personal_stats_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PersonalStatsCard extends StatelessWidget {
  final int completedCount;
  final int totalCount;
  //연속 달성일
  final int streakDays;

  const PersonalStatsCard({
    super.key,
    required this.completedCount,
    required this.totalCount,
    this.streakDays = 0,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 왼쪽 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '오늘 $completedCount개 완료',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (streakDays > 0) ...[
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streakDays일 연속',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      '${totalCount - completedCount}개 남음',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 오른쪽 원형 프로그레스
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(
                      _getProgressColor(progress),
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    final date = DateFormat('M월 d일 EEEE', 'ko').format(DateTime.now());

    if (hour < 12) return '좋은 아침이에요! $date';
    if (hour < 18) return '좋은 오후예요! $date';
    return '좋은 저녁이에요! $date';
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.5) return Colors.blue;
    if (progress >= 0.3) return Colors.orange;
    return Colors.red;
  }
}