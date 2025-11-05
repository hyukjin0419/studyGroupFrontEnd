import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/insight/weekly_insight_response.dart';
import 'package:study_group_front_end/providers/insight_provider.dart';
import 'package:study_group_front_end/util/date_calculator.dart';

class InsightScreen extends StatefulWidget {
  const InsightScreen({Key? key}) : super(key: key);

  @override
  State<InsightScreen> createState() => _InsightScreenState();
}

class _InsightScreenState extends State<InsightScreen> {
  DateTime selectedWeekStart = DateTime.now();

  late InsightProvider _insightProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      _insightProvider = context.read<InsightProvider>();
      _insightProvider.initializeContext();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InsightProvider>();
    final insight = provider.insight;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: Text(
          '인사이트',
          style: Theme.of(context).textTheme.bodyLarge!,
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildWeekSelector(provider),

            if (provider.insight == null)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Text('데이터를 불러올 수 없습니다 😢'),
              )
            else if (provider.isEmpty)
              //TODO 일단 mvp에서는 체크리스트 없으면 렌더링 자체를 안하도록 진행.
              _buildEmptyState()
            else ...[
                _buildSummaryCard(provider.insight!),
                _buildWeeklyChart(provider),
                _buildStudyActivityCard(provider.insight!),
              ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, color: Colors.grey[400], size: 72),
            const SizedBox(height: 16),
            Text(
              '이번 주에 할당된 체크리스트가 없습니다!',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildWeekSelector(InsightProvider provider) {
    final start = provider.startDateOfWeek;
    final end = start.add(const Duration(days: 6));

    String formatted = '${start.month}월 ${start.day}일 ~ ${end.month}월 ${end.day}일';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: Colors.teal[600]),
            onPressed: () => provider.moveToPreviousWeek(),
          ),
          Text(
            formatted,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: Colors.teal[600]),
            onPressed: () => provider.moveToNextWeek(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(WeeklyInsightResponse insight) {
    final completeRate = (insight.completionRate * 100).toInt();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '주간 요약',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: insight.completionRate,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.teal[600]!,
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$completeRate%',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            '완료율',
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
              const SizedBox(width: 40),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryItem('🎯', '${insight.completedCount}개 완료', '총 20개 중'),
                    const SizedBox(height: 16),
                    _buildSummaryItem('📚', '${insight.studyCount}개 스터디', '참여 중'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String emoji, String main, String sub) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              main,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            Text(
              sub,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  //TODO 없는 날은 차트가 안뜸..!
  Widget _buildWeeklyChart(InsightProvider provider) {
    final WeeklyInsightResponse? insight = provider.insight;
    final startOfWeek = provider.startDateOfWeek;

    final weekDates = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    final dailyMap = {
      for (var e in insight!.dailyChecklistCompletion)
        e.date: e.count.toDouble(),
    };

    double _getCountForDate(DateTime day, Map<DateTime, double> dailyMap) {
      for (final entry in dailyMap.entries) {
        if (isSameDate(entry.key, day)) {
          return entry.value;
        }
      }
      return 0.0;
    }

    final data = weekDates.map((d) => _getCountForDate(d, dailyMap)).toList();
    final labels = weekDates.map((d) => '${d.month}/${d.day}').toList();

    final maxValue = (data.isEmpty || data.reduce((a, b) => a > b ? a : b) <= 0)
        ? 1.0
        : data.reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '일별 완료 현황',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomBarChart(
              data: data,
              labels: labels,
              maxValue: maxValue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyActivityCard(WeeklyInsightResponse insight) {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '스터디별 활동도',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          ...insight.studyActivity.map((s) => _buildStudyItem(s.studyName, s.activityRate)),
        ],
      ),
    );
  }

  Widget _buildStudyItem(String name, double rate) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '${(rate * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rate,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.teal[600]!,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

// 커스텀 막대 차트 위젯
class CustomBarChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final double maxValue;

  const CustomBarChart({
    super.key,
    required this.data,
    required this.labels,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final safeMax = (maxValue.isNaN || maxValue <= 0) ? 1.0 : maxValue;
    log('[CustomBarChart] data=$data, maxValue=$maxValue');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(data.length, (index) {
              final ratio = (data[index] / safeMax).clamp(0.0, 1.0);
              final barHeight = (ratio * 120).clamp(0.0, 120.0);

              return Flexible(
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                        Text('${labels[index]}: ${data[index].toInt()}개'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.grey[800],
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (data[index] > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${data[index].toInt()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: barHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal[400]!,
                              Colors.teal[600]!,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: labels.map((label) {
            return Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
