import 'dart:async';
import 'dart:developer';

import 'package:rxdart/rxdart.dart';
import 'package:study_group_front_end/api_service/checklist_item_api_service.dart';
import 'package:study_group_front_end/api_service/personal_checklist_api_service.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';

class InMemoryChecklistItemRepository{
  final ChecklistItemApiService teamApi;
  final PersonalChecklistApiService personalApi;

  InMemoryChecklistItemRepository(this.teamApi, this.personalApi);

  final Map<String, ChecklistItemDetailResponse?> _cache = {};

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';

  String _studyIdMemberIdChecklistIdDateKey(int? studyId, int ?memberId, int? checklistId, DateTime date) =>
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

  void _emitFromCache() {
    final nonNullItems = _cache.values
        .whereType<ChecklistItemDetailResponse>()
        .toList();

    log("📤 emit: ${nonNullItems.length}개 (null 제외)", name: "InMemoryChecklistItemRepository");
    _subject.add(nonNullItems);
  }

  // ===========================================================
  // 🧭 FETCH
  // ===========================================================
  //우선적 캐시 호출 통합
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
        final key = _studyIdMemberIdChecklistIdDateKey(item.studyId, item.memberId, item.id, item.targetDate);
        _cache[key] = item;
      }
      for(int i=0;i<7;i++) {
        final d = startOfWeek.add(Duration(days: i));
        if (studyId != null && memberId == null) {
          final key = _studyIdMemberIdChecklistIdDateKey(studyId, null, null, d);
          //TODO create시 더미값은 지우고 바꾸어 주어야 함!!
          //TODO 상대방과의 연동은 pull to refresh 및 주기적 캐시 업데이트를 통해!
          _cache[key] = null;
        } else if (studyId == null && memberId != null) {
          final key = _studyIdMemberIdChecklistIdDateKey(null, memberId, null, d);
          _cache[key] = null;
        }
      }
      _emitFromCache();

    } catch (e) {
      log("❌ fetchChecklistsByWeek 실패: $e", name: "InMemoryChecklistItemRepository");
      rethrow;
    }
  }
}

//--------------------Optimistic Update--------------------//
  // ===========================================================
  // ✏️ CRUD / REORDER
  // ===========================================================
  // Future<void> create(int studyId, ChecklistItemCreateRequest request, String studyName) async {
  //   final key = _studyIdDateKey(studyId, request.targetDate);
  //   final tempId = -DateTime.now().millisecondsSinceEpoch;
  //
  //   final newItem = ChecklistItemDetailResponse(
  //       id: tempId,
  //       type: "STUDY",
  //       studyId: studyId,
  //       memberId: request.assigneeId,
  //       studyMemberId: -1,
  //       studyName: studyName,
  //       content: request.content,
  //       targetDate: request.targetDate,
  //       completed: false,
  //       orderIndex: (_cache[key]?.length ?? 0),
  //   );
  //
  //   _cache.putIfAbsent(key, () => []);
  //   _cache[key]!.add(newItem);
  //   _cacheToAllStreams();
  //
  //   try {
  //     final created = await teamApi.createChecklistItemOfStudy(request, studyId);
  //     final idx = _cache[key]!.indexWhere((e) => e.id == tempId);
  //     if (idx >= 0) _cache[key]![idx] = created;
  //   } catch (_) {
  //     _cache[key]!.removeWhere((e) => e.id == tempId);
  //     _cacheToAllStreams();
  //     rethrow;
  //   }
  // }
  //
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

