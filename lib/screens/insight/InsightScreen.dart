import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/insight/weekly_insight_response.dart';
import 'package:study_group_front_end/providers/insight_provider.dart';

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
          : insight == null
          ? const Center(child: Text('데이터가 없습니다 😢'))
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildWeekSelector(provider),
            _buildSummaryCard(insight),
            _buildWeeklyChart(insight),
            _buildStudyActivityCard(insight),
            const SizedBox(height: 20),
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
  Widget _buildWeeklyChart(WeeklyInsightResponse insight) {
    final data = insight.dailyChecklistCompletion.map((e) => e.count.toDouble()).toList();
    final labels = insight.dailyChecklistCompletion
        .map((e) => '${e.date.month}/${e.date.day}')
        .toList();

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
              maxValue: (data.isEmpty ? 1 : data.reduce((a, b) => a > b ? a : b)),
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
    Key? key,
    required this.data,
    required this.labels,
    required this.maxValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(data.length, (index) {
              final height = (data[index] / maxValue);
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    // 툴팁 표시
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${labels[index]}: ${data[index].toInt()}개'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.grey[800],
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 값 표시 (선택적)
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
                      // 막대
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: height * 150, // 최대 높이 150px
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
        // X축 라벨
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