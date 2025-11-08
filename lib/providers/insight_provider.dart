import 'package:flutter/material.dart';
import 'package:study_group_front_end/api_service/insight_api_service.dart';
import 'package:study_group_front_end/dto/insight/weekly_insight_response.dart';
import 'package:study_group_front_end/util/date_calculator.dart';

class InsightProvider with ChangeNotifier {
  final InsightApiService apiService;
  InsightProvider(this.apiService);

  WeeklyInsightResponse? _insight;
  bool _isLoading = false;

  //TODO -> 임시 for mvp
  bool _isEmpty = false;
  bool get isEmpty => _isEmpty;

  WeeklyInsightResponse? get insight => _insight;
  bool get isLoading => _isLoading;

  DateTime _startDateOfWeek = getSundayOfWeek(DateTime.now());
  DateTime get startDateOfWeek => _startDateOfWeek;

  void initializeContext() {
    _startDateOfWeek = getSundayOfWeek(_startDateOfWeek);
    fetchWeeklyInsight(_startDateOfWeek);
  }

  void moveToPreviousWeek() {
    _startDateOfWeek = _startDateOfWeek.subtract(const Duration(days: 7));
    fetchWeeklyInsight(_startDateOfWeek);
  }

  void moveToNextWeek() {
    _startDateOfWeek = _startDateOfWeek.add(const Duration(days: 7));
    fetchWeeklyInsight(_startDateOfWeek);
  }


  Future<void> fetchWeeklyInsight(DateTime startDate) async {
    _isLoading = true;
    _isEmpty = false;
    notifyListeners();
    try {
      final result = await apiService.getWeeklyInsight(startDate);
      _insight = result;
      _isEmpty = result.dailyChecklistCompletion.isEmpty &&
          result.studyActivity.isEmpty;
    } catch (e) {
      debugPrint('[INSIGHT_PROVIDER] Error: $e');
      _insight = null;
      _isEmpty = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
