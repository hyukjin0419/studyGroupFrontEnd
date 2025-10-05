import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:study_group_front_end/api_service/checklist_item_api_service.dart';
import 'package:study_group_front_end/dto/checklist_item/create/checklist_item_create_request.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/dto/checklist_item/update/checklist_item_content_update_request.dart';
import 'package:study_group_front_end/dto/checklist_item/update/checklist_item_reorder_request.dart';

class InMemoryChecklistItemRepository{
  final ChecklistItemApiService api;
  InMemoryChecklistItemRepository(this.api);

  final Map<String, List<ChecklistItemDetailResponse>> _cache = {};
  final Map<String, StreamController<List<ChecklistItemDetailResponse>>> _streams = {};

  //ex) 42-2025-09-12
  String _key(int studyId, DateTime date) =>
      '$studyId-${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';

  //UI에서 이 날짜의 체크리스트를 구독 할 수 있도록 Stream을 반환하는 함수
  Stream<List<ChecklistItemDetailResponse>> watch(int studyId, DateTime date){
    final key = _key(studyId,date);
    _streams.putIfAbsent(key, () => StreamController.broadcast());
    if(_cache.containsKey(key)) _streams[key]!.add(_cache[key]!);
    return _streams[key]!.stream;
  }
//--------------------Prefetch--------------------//
Future<void> prefetch() async {
    final list = await api.prefetchChecklistItems();
    _saveToCacheAndStream(list);
}

//--------------------우선적으로 캐시 호출--------------------//
  //force=true시 캐시가 있어도 무시하고 서버 데이터로 덮음
  //UI에서 특정날짜 선택시 해당하는 날짜에 대한 checklistItem을 return 해주는 함수
  Future<List<ChecklistItemDetailResponse>> getChecklistItems(int studyId, DateTime date, {bool force = false}) async {
    log("cache에서 체크리스트 데이터를 찾는 중....");
    final key = _key(studyId, date);
    if(_cache.containsKey(key) && !force) return _cache[key]!;
    return await _fetchWeek(studyId, date);
  }

//--------------------캐시에서 데이터 못찾을 시 fetch 주 단위로 Update--------------------//
  //date가 속한 주의 시작일 (월요일) 기준으로 7일씩 묶어서 가져오기
  Future<List<ChecklistItemDetailResponse>> _fetchWeek(int studyId, DateTime date, {bool pushToStream = false}) async {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final list = await api.getChecklistItemsOfStudyByWeek(studyId, startOfWeek);

    //1. 받은 데이터는 날짜별 그룹핑해서 캐시 저장
    _saveToCacheAndStream(list);

    // 2. 해당 주의 모든 날짜를 캐시에 등록 (데이터가 없어도 []로)
    for (int i = 0; i < 7; i++) {
      final d = startOfWeek.add(Duration(days: i));
      final key = _key(studyId, d);
      _cache.putIfAbsent(key, () => []); // ✅ 없으면 빈 리스트라도 넣음
      if (pushToStream && _streams.containsKey(key)) {
        _streams[key]!.add(_cache[key]!);
      }
    }

    // 호출자가 요청한 날짜 데이터만 반환
    final requestedKey = _key(studyId, date);
    _cache.putIfAbsent(requestedKey, () => []);
    return _cache[requestedKey] ?? [];
  }

  //일별 단일 호출
  Future<List<ChecklistItemDetailResponse>> _fetchDay(int studyId, DateTime date, {bool pushToStream = true}) async {
    log("cache에서 체크리스트 데이터를 찾을 수 없습니다. fetch from server 동작");
    final key = _key(studyId, date);
    final list = await api.getChecklistItemsOfStudyByDay(studyId, date);
    _cache[key] = list;
    if (pushToStream && _streams.containsKey(key)) _streams[key]!.add(list);
    return list;
  }


  //받아온 체크리스트 스터디 + 날짜별로 나눠서 캐시에 반영 + 스트림에 흘려보내기
  void _saveToCacheAndStream(
      List<ChecklistItemDetailResponse> items, {
        bool pushToStream = true,
      }) {
    // 날짜별로 그룹핑
    final Map<String, List<ChecklistItemDetailResponse>> grouped = {};
    for (final item in items) {
      final key = _key(item.studyId, item.targetDate);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }

    // 캐시에 반영 + 스트림에 push
    grouped.forEach((key, value) {
      _cache[key] = value;
      if (pushToStream && _streams.containsKey(key)) {
        _streams[key]!.add(value);
      }
    });
  }


//--------------------Optimistic Update--------------------//

  Future<void> create(int studyId, ChecklistItemCreateRequest request) async {
    final key = _key(studyId, request.targetDate);
    final tempId = -DateTime.now().millisecondsSinceEpoch;

    final newItem = ChecklistItemDetailResponse(
        id: tempId,
        type: "STUDY",
        studyId: studyId,
        studyMemberId: request.assigneeId,
        content: request.content,
        targetDate: request.targetDate,
        completed: false,
        orderIndex: (_cache[key]?.length ?? 0),
    );

    _cache.putIfAbsent(key, () => []);
    _cache[key]!.add(newItem);
    _streams[key]?.add(_cache[key]!);

    try {
      final created = await api.createChecklistItemOfStudy(request, studyId);
      final idx = _cache[key]!.indexWhere((e) => e.id == tempId);
      if (idx >= 0) _cache[key]![idx] = created;
      _streams[key]?.add(_cache[key]!);
    } catch (_) {
      _cache[key]!.removeWhere((e) => e.id == tempId);
      _streams[key]?.add(_cache[key]!);
      rethrow;
    }
  }

  Future<void> updateContent(int checklistItemId, int studyId, DateTime date, ChecklistItemContentUpdateRequest request) async {
    final key = _key(studyId, date);
    final list = _cache[key]!;
    final idx = list.indexWhere((e) => e.id == checklistItemId);
    if(idx < 0) return;

    final oldItem = list[idx];
    list[idx] = list[idx].copyWith(content: request.content);
    _streams[key]?.add(list);

    try {
      await api.updateChecklistItemContent(checklistItemId, request);
    } catch (_) {
      list[idx] = oldItem;
      _streams[key]?.add(list);
      rethrow;
    }
  }

  Future<void> toggleStatus(int checklistItemId, int studyId, DateTime date) async {
    final key = _key(studyId, date);
    final list = _cache[key]!;
    final idx = list.indexWhere((e) => e.id == checklistItemId);
    if(idx < 0) return;

    final oldCompleted = list[idx].completed;
    list[idx] = list[idx].copyWith(completed: !oldCompleted);
    _streams[key]?.add(list);

    try {
      await api.updateChecklistItemStatus(checklistItemId);
    } catch (_) {
      list[idx] = list[idx].copyWith(completed: oldCompleted);
      _streams[key]?.add(list);
      rethrow;
    }
  }

  Future<void> softDelete(int checklistItemId, int studyId, DateTime date) async {
    final key = _key(studyId, date);
    final list = _cache[key]!;
    final idx = list.indexWhere((e) => e.id == checklistItemId);
    if (idx < 0) return;

    final removedItem = list[idx];
    list.removeAt(idx);
    _streams[key]?.add(list);

    try {
      await api.softDeleteChecklistItems(checklistItemId);
    } catch (_) {
      list.insert(idx, removedItem);
      _streams[key]?.add(list);
      rethrow;
    }
  }
  
  Future<void> reorder(List<ChecklistItemReorderRequest> requests, int studyId, DateTime date) async {
    final key = _key(studyId, date);
    final list = _cache[key]!;
    
    final oldList = List.of(list);
    for (final req in requests) {
      final idx = list.indexWhere((e) => e.id == req.checklistItemId);
      if(idx >= 0) {
        list[idx] = list[idx].copyWith(
          studyMemberId: req.studyMemberId,
          orderIndex: req.orderIndex,
        );
      }
    }
    _streams[key]?.add(list);
    try {
      await api.reorderChecklistItem(requests);
    } catch (_) {
      _cache[key] = oldList;
      _streams[key]?.add(oldList);
      rethrow;
    }
  }
}