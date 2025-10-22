import 'dart:async';
import 'dart:developer';

import 'package:rxdart/rxdart.dart';
import 'package:study_group_front_end/api_service/checklist_item_api_service.dart';
import 'package:study_group_front_end/api_service/personal_checklist_api_service.dart';
import 'package:study_group_front_end/dto/checklist_item/create/checklist_item_create_request.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';

class InMemoryChecklistItemRepository{
  final ChecklistItemApiService teamApi;
  final PersonalChecklistApiService personalApi;

  InMemoryChecklistItemRepository(this.teamApi, this.personalApi);

  final Map<String, ChecklistItemDetailResponse?> _cache = {};

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';

  String _studyIdMemberIdChecklistIdDateKey({int? studyId, int ?memberId, int? checklistId,required DateTime date}) =>
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

  static final BehaviorSubject<List<ChecklistItemDetailResponse>> _subject = BehaviorSubject.seeded([]);
  Stream<List<ChecklistItemDetailResponse>> get stream => _subject.stream;

  // void _emitFromCache() {
  //   final nonNullItems = _cache.values
  //       .whereType<ChecklistItemDetailResponse>()
  //       .toList();
  //
  //   log("📤 emit: ${nonNullItems.length}개 (null 제외)", name: "InMemoryChecklistItemRepository");
  //   _subject.add(nonNullItems);
  // }

  void _emitFromCache({ChecklistItemDetailResponse? newItem}) {
    if (newItem != null) {
      // ✅ 개별 아이템만 추가 발행
      log("📤 emit(단일): ${newItem.id} (${newItem.content})",
          name: "InMemoryChecklistItemRepository");
      _subject.add([newItem]); // Stream<List<...>> 형태 유지 시, 단일 리스트로 래핑
      return;
    }

    // ✅ 초기 동기화나 캐시 전체 반영 시 (fallback)
    final nonNullItems = _cache.values
        .whereType<ChecklistItemDetailResponse>()
        .toList();

    log("📤 emit(전체): ${nonNullItems.length}개 (null 제외)",
        name: "InMemoryChecklistItemRepository");
    _subject.add(nonNullItems);
  }


  Future<void> fetchChecklistByWeek({required DateTime date, int? studyId, int? memberId, bool force = false}) async {
    final keyDate = DateTime(date.year, date.month, date.day);
    log("studyId $studyId, memberId $memberId", name: "InMemoryChecklistItemRepository");
    final hit = cacheHit(memberId:memberId, studyId: studyId, date: date);

    log("캐시 히트? $hit", name: "InMemoryChecklistItemRepository");
    if (hit && !force){
      log("💾 캐시 히트 → API 호출 스킵", name: "InMemoryChecklistItemRepository");
      _emitFromCache();
      return;
    }
    log("🔍 캐시 미스 -> 데이터 fetch후 빈 날짜 더미 캐시값으로 생성", name: "InMemoryChecklistItemRepository");

    try {
      final startOfWeek = date.subtract(Duration(days: date.weekday % 7));
      List<ChecklistItemDetailResponse> fetched;
      if (studyId != null && memberId == null) {
        log('🚀 [스터디 체크리스트] 서버 fetch 실행: studyId=$studyId / $keyDate', name: "InMemoryChecklistItemRepository");
        fetched = await teamApi.getChecklistItemsOfStudyByWeek(studyId, startOfWeek);
      } else if (studyId == null && memberId != null) {
        log('🚀 [개인 체크리스트] 서버 fetch 실행: memberId=$memberId / $keyDate', name: "InMemoryChecklistItemRepository");
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
          //TODO create시 더미값은 지우고 바꾸어 주어야 함!!
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


//--------------------Optimistic Update x--------------------//
  // ===========================================================
  // ✏️ CRUD / REORDER
  // ===========================================================
  Future<void> createChecklistItem({
    required int studyId,
    required ChecklistItemCreateRequest request,
    required bool fromStudy,
  }) async {
    try {
      final created = await teamApi.createChecklistItemOfStudy(request, studyId);

      //기존에 있던 dummy key 삭제 - from study
      String tempKey = "";
      if(fromStudy){
        tempKey =_studyIdMemberIdChecklistIdDateKey(studyId: studyId, date: request.targetDate);
      }
      //TODO form personal도 필요함
      _cache.remove(tempKey);

      log("realkey 만들어서 캐시에 아이템 추가", name: "InMemoryChecklistItemRepository");
      final realKey = _studyIdMemberIdChecklistIdDateKey(studyId: created.studyId, memberId: created.memberId, checklistId: created.id, date: created.targetDate);
      _cache[realKey] = created;

      _emitFromCache(newItem: created);
    } catch (e, stackTrace) {
      log("createdChecklistItem error $e", name: "InMemoryChecklistItemRepository");
      log("📍 Stack trace: $stackTrace", name: "InMemoryChecklistItemRepository");

      _emitFromCache();
      rethrow;
    }
  }

  // Future<void> updateContent(int checklistItemId, int studyId, DateTime date, ChecklistItemContentUpdateRequest request) async {
  //   final key = _studyIdDateKey(studyId, date);
  //   final list = _cache[key]!;
  //
  //   final idx = list.indexWhere((e) => e.id == checklistItemId);
  //   if(idx < 0) return;
  //
  //   final oldItem = list[idx];
  //   final updatedItem = list[idx] = list[idx].copyWith(content: request.content);
  //   list[idx] = updatedItem;
  //   _saveToCacheAndStream([updatedItem]);
  //
  //   try {
  //     await teamApi.updateChecklistItemContent(checklistItemId, request);
  //   } catch (_) {
  //     list[idx] = oldItem;
  //     _saveToCacheAndStream([oldItem]);
  //     rethrow;
  //   }
  // }
  //
  // Future<void> toggleStatus(int checklistItemId, int studyId, DateTime date) async {
  //   final key = _studyIdDateKey(studyId, date);
  //   final list = _cache[key]!;
  //   final idx = list.indexWhere((e) => e.id == checklistItemId);
  //   if(idx < 0) return;
  //
  //   final oldItem = list[idx];
  //   final updatedItem = list[idx] = list[idx].copyWith(completed: !oldItem.completed);
  //   _saveToCacheAndStream([updatedItem]);
  //
  //   try {
  //     await teamApi.updateChecklistItemStatus(checklistItemId);
  //   } catch (_) {
  //     list[idx] = oldItem;
  //     _saveToCacheAndStream([oldItem]);
  //     rethrow;
  //   }
  // }
  //
  // Future<void> softDelete(int checklistItemId, int studyId, DateTime date) async {
  //   final key = _studyIdDateKey(studyId, date);
  //   final list = _cache[key]!;
  //   final idx = list.indexWhere((e) => e.id == checklistItemId);
  //   if (idx < 0) return;
  //
  //   final removedItem = list[idx];
  //   list.removeAt(idx);
  //   _saveToCacheAndStream(list);
  //
  //   try {
  //     await teamApi.softDeleteChecklistItems(checklistItemId);
  //   } catch (_) {
  //     list.insert(idx, removedItem);
  //     _saveToCacheAndStream(list);
  //     rethrow;
  //   }
  // }
  //
  // Future<void> reorder(List<ChecklistItemReorderRequest> requests, int studyId, DateTime date) async {
  //   final key = _studyIdDateKey(studyId, date);
  //   final list = _cache[key]!;
  //
  //   final oldList = List.of(list);
  //
  //   for (final req in requests) {
  //     final idx = list.indexWhere((e) => e.id == req.checklistItemId);
  //     if(idx >= 0) {
  //       list[idx] = list[idx].copyWith(
  //         studyMemberId: req.studyMemberId,
  //         orderIndex: req.orderIndex,
  //       );
  //     }
  //   }
  //   _saveToCacheAndStream(list);
  //   try {
  //     await teamApi.reorderChecklistItem(requests);
  //   } catch (_) {
  //     _cache[key] = oldList;
  //     _saveToCacheAndStream(oldList);
  //     rethrow;
  //   }
  // }
}
