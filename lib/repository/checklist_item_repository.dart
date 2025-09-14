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

  Stream<List<ChecklistItemDetailResponse>> watch(int studyId, DateTime date){
    final key = _key(studyId,date);
    _streams.putIfAbsent(key, () => StreamController.broadcast());
    if(_cache.containsKey(key)) _streams[key]!.add(_cache[key]!);
    return _streams[key]!.stream;
  }

  Future<List<ChecklistItemDetailResponse>> getChecklistItems(int studyId, DateTime date, {bool force = false}) async {
    log("cache에서 체크리스트 데이터를 찾는 중....");
    final key = _key(studyId, date);
    if(_cache.containsKey(key) && !force) return _cache[key]!;
    return await _fetchAndCache(studyId, date);
  }

  Future<List<ChecklistItemDetailResponse>> _fetchAndCache(int studyId, DateTime date, {bool pushToStream = true}) async {
    log("cache에서 체크리스트 데이터를 찾을 수 없습니다. fetch from server 동작");
    final key = _key(studyId, date);
    final list = await api.getChecklistItemsOfStudy(studyId, date);
    _cache[key] = list;
    if (pushToStream && _streams.containsKey(key)) _streams[key]!.add(list);
    return list;
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

    final oldItem = list[idx];
    list[idx] = list[idx].copyWith(completed: !oldItem.completed);
    _streams[key]?.add(list);

    try {
      await api.updateChecklistItemStatus(checklistItemId);
    } catch (_) {
      list[idx] = oldItem;
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