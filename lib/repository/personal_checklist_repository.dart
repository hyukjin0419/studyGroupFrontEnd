// repository/personal_checklist_repository.dart

import 'dart:async';
import 'dart:developer';
import 'package:study_group_front_end/api_service/checklist_item_api_service.dart';
import 'package:study_group_front_end/api_service/personal_checklist_api_service.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/dto/checklist_item/update/checklist_item_content_update_request.dart';

class PersonalChecklistRepository {
  final PersonalChecklistApiService personalApi;
  final ChecklistItemApiService commonApi;

  PersonalChecklistRepository(this.personalApi, this.commonApi);

  final Map<String, List<ChecklistItemDetailResponse>> _cache = {};
  final Map<String, StreamController<List<ChecklistItemDetailResponse>>> _streams = {};

  String _key(DateTime date) =>
      'personal-${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';

  Stream<List<ChecklistItemDetailResponse>> watch(DateTime date){
    final key = _key(date);
    _streams.putIfAbsent(key, () => StreamController.broadcast());

    if(_cache.containsKey(key)) _streams[key]!.add(_cache[key]!);

    return _streams[key]!.stream;
  }

  // ==================== READ ====================

  Future<List<ChecklistItemDetailResponse>> getMyChecklistsOfDay(DateTime date, {bool force = false}) async {
    final key = _key(date);
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));

    if (!force && _cache.containsKey(key)) {
      log("PersonalRepo: 캐시 히트");
      return List.from(_cache[key]!);
    }

    // 캐시 미스 - 주간 데이터 가져오기
    log("personal cache miss");
    log("PersonalRepo: API 호출");
    await _fetchAndCacheWeek(startOfWeek);

    return _cache[key] ?? [];
  }

  Future<void> _fetchAndCacheWeek(DateTime startOfWeek) async {
    try {
      final items = await personalApi.getMyChecklistsByWeek(startOfWeek);

      //7일 캐시 초기화
      for(int i=0;i<7;i++) {
        final day = startOfWeek.add(Duration(days: i));
        _cache[_key(day)] = [];
      }

      //캐시에 체크리스트의 targetDate 확인해서 날짜별로 채워넣기
      for (final item in items) {
        final itemKey = _key(item.targetDate);
        _cache[itemKey]!.add(item);
      }

      //업데이트 된 내용 Stream에 전파하기
      for(int i=0;i<7;i++) {
        final day = startOfWeek.add(Duration(days: i));
        final dayKey = _key(day);
        if(_streams.containsKey(dayKey)) {
          _streams[dayKey]!.add(List.from(_cache[dayKey]!));
        }
      }

      log("PersonalRepo: 주간 데이터 캐싱 완료");
    } catch (e) {
      log("PersonalRepo: 주간 데이터 조회 실패 - $e");
      rethrow;
    }
  }

//TODO Check CRUD of Repository
  // ==================== UPDATE ====================
  Future<void> toggleStatus(int checklistItemId, DateTime date) async {
    final key = _key(date);
    final list = _cache[key];
    final index = list!.indexWhere((e) => e.id == checklistItemId);
    if(index < 0) return;

    final oldCompleted = list[index].completed;
    list[index] = list[index].copyWith(completed: !oldCompleted);
    _streams[key]?.add(List.from(list));

    try{
      await commonApi.updateChecklistItemStatus(checklistItemId);
    } catch (e) {
      list[index] = list[index].copyWith(completed: oldCompleted);
      _streams[key]?.add(List.from(list));
      rethrow;
    }
  }

  Future<void> updateContent(int checklistItemId, DateTime date, String content) async {
    final request = ChecklistItemContentUpdateRequest(content: content);
    await commonApi.updateChecklistItemContent(checklistItemId, request);

    // 캐시 업데이트
    final key = _key(date);
    if (_cache.containsKey(key)) {
      final index = _cache[key]!.indexWhere((e) => e.id == checklistItemId);
      if (index >= 0) {
        _cache[key]![index] = _cache[key]![index].copyWith(content: content);
      }
    }
  }

  // ==================== DELETE ====================

  Future<void> deleteItem(int checklistItemId, DateTime date) async {
    await commonApi.softDeleteChecklistItems(checklistItemId);

    // 캐시에서 제거
    final key = _key(date);
    if (_cache.containsKey(key)) {
      _cache[key]!.removeWhere((e) => e.id == checklistItemId);
    }
  }

  // ==================== UTILS ====================
  void clearCache() {
    _cache.clear();
  }

  void clearDateCache(DateTime date) {
    log("clear cache");
    _cache.remove(_key(date));
  }
}