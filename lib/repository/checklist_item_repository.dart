import 'dart:async';
import 'dart:developer';

import 'package:rxdart/rxdart.dart';
import 'package:study_group_front_end/api_service/checklist_item_api_service.dart';
import 'package:study_group_front_end/api_service/personal_checklist_api_service.dart';
import 'package:study_group_front_end/dto/checklist_item/create/checklist_item_create_request.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/dto/checklist_item/update/checklist_item_reorder_request.dart';

class InMemoryChecklistItemRepository{
  final ChecklistItemApiService teamApi;
  final PersonalChecklistApiService personalApi;

  InMemoryChecklistItemRepository(this.teamApi, this.personalApi);

  final Map<String, ChecklistItemDetailResponse?> _cache = {};

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';

  String _studyIdMemberIdChecklistIdDateKey({int? studyId, int ?memberId, int? checklistId, required DateTime date}) =>
      '${studyId}_${memberId}_${checklistId}_${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  bool cacheHit({int? studyId, int? memberId, required DateTime date}) {
    final dateKey = _dateKey(date);

    if (studyId == null && memberId != null) {
      // 패턴: *_memberId_checklistId_date
      return _cache.keys.any((key) {
        final parts = key.split('_');
        if (parts.length != 4) return false;

        return parts[1] == memberId.toString() && parts[3] == dateKey;
      });
    }

    if (studyId != null && memberId == null) {
      // 패턴: studyId_*_checklistId_date
      return _cache.keys.any((key) {
        final parts = key.split('_');
        if (parts.length != 4) return false;

        return parts[0] == studyId.toString() && parts[3] == dateKey;
      });
    }

    return false;
  }

  static final BehaviorSubject<(bool delete, List<ChecklistItemDetailResponse> items)> _subject = BehaviorSubject.seeded((false, []));

  Stream<(bool delete, List<ChecklistItemDetailResponse> items)> get stream => _subject.stream;

  void _emitFromCache({ChecklistItemDetailResponse? newItem, bool delete = false}) {
    if (newItem != null) {
      // log("📤 emit(단일): ${newItem.id} (${newItem.content})",
      //     name: "InMemoryChecklistItemRepository");
      _subject.add((false, [newItem]));
      return;
    }

    final nonNullItems = _cache.values
        .whereType<ChecklistItemDetailResponse>()
        .toList();

    if(delete){
      // log("📤 emit(전체) with delete = true: ${nonNullItems.length}개 (null 제외)",
      //     name: "InMemoryChecklistItemRepository");
      _subject.add((true, nonNullItems));
      return;
    }

    // log("📤 emit(전체): ${nonNullItems.length}개 (null 제외)",
    //     name: "InMemoryChecklistItemRepository");
    _subject.add((false,nonNullItems));
  }


  Future<void> fetchChecklistByWeek({required DateTime date, int? studyId, int? memberId, bool force = false}) async {
    if(force == true) {
      _cache.clear();
      log("clear cache");
      _emitFromCache(delete: true);
    }
    final keyDate = DateTime(date.year, date.month, date.day);
    log("studyId $studyId, memberId $memberId", name: "InMemoryChecklistItemRepository");
    final hit = cacheHit(memberId:memberId, studyId: studyId, date: date);

    // log("캐시 히트? $hit", name: "InMemoryChecklistItemRepository");
    if (hit && !force){
      // log("💾 캐시 히트 → API 호출 스킵", name: "InMemoryChecklistItemRepository");
      _emitFromCache();
      return;
    }
    // log("🔍 캐시 미스 -> 데이터 fetch후 빈 날짜 더미 캐시값으로 생성", name: "InMemoryChecklistItemRepository");

    try {
      final startOfWeek = date.subtract(Duration(days: date.weekday % 7));
      List<ChecklistItemDetailResponse> fetched;
      if (studyId != null && memberId == null) {
        // log('🚀 [스터디 체크리스트] 서버 fetch 실행: studyId=$studyId / $keyDate', name: "InMemoryChecklistItemRepository");
        fetched = await teamApi.getChecklistItemsOfStudyByWeek(studyId, startOfWeek);
      } else if (studyId == null && memberId != null) {
        // log('🚀 [개인 체크리스트] 서버 fetch 실행: memberId=$memberId / $keyDate', name: "InMemoryChecklistItemRepository");
        fetched = await personalApi.getMyChecklistsByWeek(startOfWeek);
      } else {
        throw ArgumentError("study Id 또는 MemberId 중 하나는 반드시 지정되어야 합니다.");
      }
      for (var item in fetched){
        final key = _studyIdMemberIdChecklistIdDateKey(studyId: item.studyId, memberId: item.memberId, checklistId: item.id, date: item.targetDate);
        _cache[key] = item;
      }
      for(int i=0;i<7;i++) {
        final d = startOfWeek.add(Duration(days: i));
        if (studyId != null && memberId == null) {
          final key = _studyIdMemberIdChecklistIdDateKey(studyId: studyId,date: d);
          //TODO 상대방과의 연동은 pull to refresh 및 주기적 캐시 업데이트를 통해!
          _cache[key] = null;
        } else if (studyId == null && memberId != null) {
          final key = _studyIdMemberIdChecklistIdDateKey(memberId: memberId,date: d);
          _cache[key] = null;
        }
      }
      _emitFromCache();

    } catch (e) {
      log("❌ fetchChecklistsByWeek 실패: $e", name: "InMemoryChecklistItemRepository");
      rethrow;
    }
  }

  void clearAllCache() {
    _cache.clear();
    log("🧹 모든 checklist 캐시 비움 완료", name: "[ChecklistRepository]");
    _emitFromCache(delete: true);
  }


//--------------------Optimistic Update x--------------------//
  // ===========================================================
  // ✏️ CRUD / REORDER
  // ===========================================================
  Future<void> createChecklistItem({
    required int studyId,
    int? memberId,
    required ChecklistItemCreateRequest request,
    required bool fromStudy,
  }) async {
    try {
      final created = await teamApi.createChecklistItemOfStudy(request, studyId);

      String tempKey = "";
      if(fromStudy){
        tempKey =_studyIdMemberIdChecklistIdDateKey(studyId: studyId, date: request.targetDate);
      } else {
        tempKey =_studyIdMemberIdChecklistIdDateKey(memberId: memberId, date: request.targetDate);
      }

      bool keyExisted = _cache.containsKey(tempKey);
      // log("삭제전 $keyExisted", name: "InMemoryChecklistItemRepository");
      _cache.remove(tempKey);
      keyExisted = _cache.containsKey(tempKey);
      // log("삭제후 $keyExisted", name: "InMemoryChecklistItemRepository");


      // log("realkey 만들어서 캐시에 아이템 추가", name: "InMemoryChecklistItemRepository");
      final realKey = _studyIdMemberIdChecklistIdDateKey(studyId: created.studyId, memberId: created.memberId, checklistId: created.id, date: created.targetDate);
      _cache[realKey] = created;

      _emitFromCache(newItem: created);
    } catch (e, stackTrace) {
      log("createdChecklistItem error $e", name: "InMemoryChecklistItemRepository");
      log("📍 Stack trace: $stackTrace", name: "InMemoryChecklistItemRepository");
      rethrow;
    }
  }

  Future<void> updateContent(ChecklistItemDetailResponse newItem) async {
    final key = _studyIdMemberIdChecklistIdDateKey(studyId: newItem.studyId, memberId: newItem.memberId, checklistId: newItem.id, date: newItem.targetDate);
    final oldItem = _cache[key];
    _cache[key] = newItem;
    _emitFromCache();

    try {
      await teamApi.updateChecklistItemContent(newItem);
    } catch (e, stackTrace) {
      _cache[key] = oldItem;
      log("createdChecklistItem error $e", name: "InMemoryChecklistItemRepository");
      log("📍 Stack trace: $stackTrace", name: "InMemoryChecklistItemRepository");
      rethrow;
    }
  }
  //
  Future<void> toggleStatus(ChecklistItemDetailResponse item) async {
    final key = _studyIdMemberIdChecklistIdDateKey(studyId: item.studyId, memberId: item.memberId, checklistId: item.id, date: item.targetDate);

    final oldItem = _cache[key];
    final newItem = item.copyWith(completed: !item.completed);
    _cache[key] = newItem;
    _emitFromCache();

    try {
      await teamApi.updateChecklistItemStatus(item.id);
    } catch (e, stackTrace) {
      _cache[key] = oldItem;
      log("createdChecklistItem error $e", name: "InMemoryChecklistItemRepository");
      log("📍 Stack trace: $stackTrace", name: "InMemoryChecklistItemRepository");
      rethrow;
    }
  }

  Future<void> softDelete(ChecklistItemDetailResponse item) async {
    final key = _studyIdMemberIdChecklistIdDateKey(studyId: item.studyId, memberId: item.memberId, checklistId: item.id, date: item.targetDate);

    final oldItem = _cache[key];
    _cache.remove(key);
    _emitFromCache(delete: true);

    try {
      await teamApi.softDeleteChecklistItems(item.id);
    } catch (e, stackTrace) {
      _cache[key] = oldItem;
      log("createdChecklistItem error $e", name: "InMemoryChecklistItemRepository");
      log("📍 Stack trace: $stackTrace", name: "InMemoryChecklistItemRepository");
      rethrow;
    }
  }

  void updateCacheAfterReorder(List<ChecklistItemDetailResponse> reorderedItems, DateTime date){
    for (final item in reorderedItems) {
      _cache.removeWhere((key, value) => value?.id == item.id);

      final newKey = _studyIdMemberIdChecklistIdDateKey(
        studyId: item.studyId,
        memberId: item.memberId,
        checklistId: item.id,
        date: item.targetDate,
      );
      _cache[newKey] = item;
    }

    _emitFromCache(delete: true);
  }

  Future<void> reorder(List<ChecklistItemDetailResponse> items, DateTime date) async {
    try {
      final requests = items
          .map((e) => ChecklistItemReorderRequest.fromDetail(e))
          .toList();

      await teamApi.reorderChecklistItem(requests);

      for (final item in items) {
        final key = _studyIdMemberIdChecklistIdDateKey(
            studyId: item.studyId,
            memberId: item.memberId,
            checklistId: item.id,
            date: date);
        _cache[key] = item;
      }

      _emitFromCache(delete: true);
    } catch (e, stackTrace) {

      log("createdChecklistItem error $e", name: "InMemoryChecklistItemRepository");
      log("📍 Stack trace: $stackTrace", name: "InMemoryChecklistItemRepository");
      rethrow;
    }
  }
}
