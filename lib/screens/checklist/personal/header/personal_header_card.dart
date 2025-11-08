// screens/checklist/personal/widgets/personal_stats_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PersonalStatsCard extends StatelessWidget {
  final int completedCount;
  final int totalCount;

  const PersonalStatsCard({
    super.key,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final remaining = totalCount - completedCount;
    final greeting = _getGreeting();
    final progressColor = _getProgressColor(progress);
    final feedback = _getProgressMessage(progress);

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
                //상단인사
                Text(
                  greeting,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                //완료 현왕
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
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        feedback,
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 12),
                    Text('$remaining개 남았어요',
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
                      progressColor,
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

  //TODO MVP이후 위치기반 날씨 추가하기
  String _getGreeting() {
    final now = DateTime.now();
    final hour = now.hour;
    final date = DateFormat('M월 d일 EEEE', 'ko').format(now);

    if (hour >= 5 && hour < 11) {
      return '좋은 아침이에요 ☀️ $date';
    } else if (hour >= 11 && hour < 14) {
      return '좋은 점심이에요 🍽️ $date';
    } else if (hour >= 14 && hour < 18) {
      return '좋은 오후에요 🌤️ $date';
    } else if (hour >= 18 && hour < 22) {
      return '좋은 저녁이에요 🌇 $date';
    } else if (hour >= 22 || hour < 2) {
      return '좋은 밤이에요 🌙 $date';
    } else {
      return '좋은 새벽이에요 🌌 $date';
    }
  }


  String _getProgressMessage(double progress) {
    if (progress == 1.0) return '오늘 목표 달성! 🎉';
    if (progress >= 0.7) return '거의 다 왔어요 🔥';
    if (progress >= 0.4) return '좋아요, 절반 넘었어요 🙌';
    if (progress > 0.0) return '시작이 반이에요 💪';
    return '이제 시작해볼까요? 🚀';
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.5) return Colors.blue;
    if (progress >= 0.3) return Colors.orange;
    return Colors.red;
  }
}