import 'dart:async';
import 'dart:developer';

import 'package:study_group_front_end/api_service/checklist_item_api_service.dart';
import 'package:study_group_front_end/api_service/personal_checklist_api_service.dart';
import 'package:study_group_front_end/dto/checklist_item/create/checklist_item_create_request.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/dto/checklist_item/update/checklist_item_content_update_request.dart';
import 'package:study_group_front_end/dto/checklist_item/update/checklist_item_reorder_request.dart';

class InMemoryChecklistItemRepository{
  final ChecklistItemApiService teamApi;
  final PersonalChecklistApiService personalApi;
  final int currentMemberId;
  InMemoryChecklistItemRepository(this.teamApi, this.personalApi, this.currentMemberId);

  final Map<String, List<ChecklistItemDetailResponse>> _cache = {};
  final Map<String, StreamController<List<ChecklistItemDetailResponse>>> _teamStreams = {};
  final Map<String, StreamController<List<ChecklistItemDetailResponse>>> _personalStreams = {};

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';

  // ===========================================================
  // 🧭 FETCH
  // ===========================================================
  //우선적 캐시 호출
  Future<void> getTeamChecklist(int studyId, DateTime date, {bool force = false}) async {
    final dateKey = _dateKey(date);

    if(!_cache.containsKey(dateKey) || force){
      log("getTeamChecklist 캐시 Miss or 강제 Fetch");
      await fetchWeekForTeam(studyId, date);
    } else {
      log("getTeamChecklist 캐시 히트");
      _cacheToAllStreams();
    }
  }

  Future<void> getPersonalChecklist(DateTime date ,{bool force = false}) async {
    final dateKey = _dateKey(date);

    if(!_cache.containsKey(dateKey) || force){
      log("getPersonal Checklist 캐시 miss or 강제 fetch");
      await fetchWeekForPersonal(date);
    } else {
      log("getTeamChecklist 캐시 히트");
      _cacheToAllStreams();
    }
  }

  // 팀용 체크리스트를 공통 캐시에 fetch
  Future<void> fetchWeekForTeam(int studyId, DateTime date) async{
    try {
      final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
      final list = await teamApi.getChecklistItemsOfStudyByWeek(studyId, startOfWeek);
      _apiToCache(list);
      _fillEmptyDaysInCache(startOfWeek);
      _cacheToAllStreams();
    } catch (e) {
      log('❌ [ChecklistRepo] fetchWeekForTeam 실패: $e');
      rethrow;
    }
  }

  // //개인용 체크리스트를 공통 캐시에 fetch
  Future<void> fetchWeekForPersonal(DateTime date) async{
    try{
      final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
      final list = await personalApi.getMyChecklistsByWeek(startOfWeek);
      _apiToCache(list);
      _fillEmptyDaysInCache(startOfWeek);
      _cacheToAllStreams();
    } catch (e) {
      log('❌ [ChecklistRepo] fetchWeekForPersonal 실패: $e');
      rethrow;
    }
  }

  // ===========================================================
  // 📡 STREAM  단순 채널 열고 캐시 데이터 방출 -> 캐시 데이터 로드 여기서 금지 -> 채널 열기만 하기
  // ===========================================================
  Stream<List<ChecklistItemDetailResponse>> watchTeam(int studyId, DateTime date) {
    final streamKey = 'team_${studyId}_${_dateKey(date)}';
    _teamStreams.putIfAbsent(streamKey, () => StreamController.broadcast());

    log("✅ watchTeam 리턴 직전: ${_teamStreams[streamKey]!.hasListener ? "리스너 있음" : "리스너 없음"}");

    return _teamStreams[streamKey]!.stream;
  }

  Future<Stream<List<ChecklistItemDetailResponse>>> watchPersonal(DateTime date) async{
    final streamKey = 'personal_${_dateKey(date)}';
    _personalStreams.putIfAbsent(streamKey, () => StreamController.broadcast());

    log("✅ watchPersonal 리턴 직전: ${_personalStreams[streamKey]!.hasListener ? "리스너 있음" : "리스너 없음"}");

    return _personalStreams[streamKey]!.stream;
  }
  // ===========================================================
  // 🧠 CACHE + STREAM SYNC
  // ===========================================================
  //api to cache
  void _apiToCache(List<ChecklistItemDetailResponse> items){
    for (final item in items){
      final dateKey = _dateKey(item.targetDate);
      _cache.putIfAbsent(dateKey, () => []);
      final list = _cache[dateKey]!;

      final idx = list.indexWhere((e) => e.id == item.id);
      if(idx >= 0){
        list[idx] = item;
      } else {
        list.add(item);
      }
    }
    log("💾 [Cache] ${items.length}개 저장 완료");
  }

  //이건 cache hit시 cache를 stream으로 흘려보내기
  void _cacheToAllStreams() {
    log("📡 [cacheToAllStreams] 전체 캐시를 Stream으로 재전송 시작");

    _cache.forEach((dateKey, list) {
      // --- 팀별 스트림 전송 ---
      if (list.isEmpty) {
        //캐시에 빈 배열도 일단은 빈 그대로 Push 한ㄷ다
        //ui에 빈 배열 만들어 줘야지 headerchip이 렌더링 되고 작동함.
        for (final streamKey in _teamStreams.keys.where((k) => k.contains(dateKey))) {
          _teamStreams[streamKey]?.add([]);
          log("   ⚪️ empty push → $streamKey to teamStream");
        }

        for(final streamKey in _personalStreams.keys.where((k) => k.contains(dateKey))) {
          _personalStreams[streamKey]?.add([]);
          log("   ⚪️ empty push → $streamKey to personalStream");
        }
      } else {
        for (final item in list) {
          final teamStreamKey = 'team_${item.studyId}_$dateKey';
          _teamStreams.putIfAbsent(teamStreamKey, () => StreamController.broadcast());
          final teamItems = list.where((e) => e.studyId == item.studyId).toList();
          _teamStreams[teamStreamKey]!.add(teamItems);

          final personalStreamKey = 'personal_$dateKey';
          _personalStreams.putIfAbsent(personalStreamKey, () => StreamController.broadcast());
          final personalItems = list.where((e) => e.studyMemberId == currentMemberId).toList();
          _personalStreams[personalStreamKey]!.add(personalItems);
          // log("   🔸 team_stream → $teamStreamKey (${teamItems.length} items)");
          log("   🔸 personal_stream → $personalStreamKey (${personalItems.length} items)");
        }
      }
    });

    log("✅ [cacheToAllStreams] 전체 캐시 재전송 완료 (총 ${_cache.length}일)");
  }


  //이건 cass miss 시 api  호출후 캐시 + stream update
  void _saveToCacheAndStream(List<ChecklistItemDetailResponse> items){
    _apiToCache(items);
    _cacheToAllStreams();
    // log("saveToCacheAndStream");
    // for(final item in items){
    //   final dateKey = _dateKey(item.targetDate);
    //   _cache.putIfAbsent(dateKey,() => []);
    //   final list = _cache[dateKey]!;
    //
    //   final idx = list.indexWhere((e) => e.id == item.id);
    //   if(idx >= 0){
    //     list[idx] = item;
    //   } else {
    //     list.add(item);
    //   }
    //
    //   final teamStreamKey = 'team_${item.studyId}_$dateKey';
    //   _streams.putIfAbsent(teamStreamKey, () => StreamController.broadcast());
    //   if(_streams.containsKey(teamStreamKey)) {
    //     final teamItems = list.where((e) => e.studyId == item.studyId).toList();
    //
    //     _streams[teamStreamKey]!.add(teamItems);
    //   }
    //
    //   if(item.studyMemberId == currentMemberId){
    //     final personalStreamKey = 'personal_$dateKey';
    //     _streams.putIfAbsent(personalStreamKey, () => StreamController.broadcast());
    //     log("teamStreamKey in saveToCacheAndStream $teamStreamKey}");
    //     if(_streams.containsKey(personalStreamKey)) {
    //       final personalItems = list.where((e) => e.studyMemberId == currentMemberId).toList();
    //       _streams[personalStreamKey]!.add(personalItems);
    //     }
    //   }
    // }
  }


  void _fillEmptyDaysInCache(DateTime startOfWeek) {
    for (int i = 0; i < 7; i++) {
      final d = startOfWeek.add(Duration(days: i));
      final key = _dateKey(d);
      _cache.putIfAbsent(key, () => []);
    }
    log("🗓️ [Cache] ${startOfWeek.toString().split(' ').first} 주차의 7일 캐시 초기화 완료 (총 ${_cache.length}일)");
  }

// //--------------------우선적으로 캐시 호출--------------------//
//   //force=true시 캐시가 있어도 무시하고 서버 데이터로 덮음
//   //UI에서 특정날짜 선택시 해당하는 날짜에 대한 checklistItem을 return 해주는 함수
//   Future<List<ChecklistItemDetailResponse>> getChecklistItems(int studyId, DateTime date, {bool force = false}) async {
//     log("cache에서 체크리스트 데이터를 찾는 중....");
//     final key = _key(studyId, date);
//     if(_cache.containsKey(key) && !force) return _cache[key]!;
//     return await _fetchWeek(studyId, date);
//   }

//--------------------캐시에서 데이터 못찾을 시 fetch 주 단위로 Update--------------------//
  //date가 속한 주의 시작일 (월요일) 기준으로 7일씩 묶어서 가져오기
  // Future<List<ChecklistItemDetailResponse>> _fetchWeek(int studyId, DateTime date, {bool pushToStream = false}) async {
  //   log("_fetchByWeek");
  //   final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
  //   final list = await api.getChecklistItemsOfStudyByWeek(studyId, startOfWeek);
  //
  //   //1. 받은 데이터는 날짜별 그룹핑해서 캐시 저장
  //   _saveToCacheAndStream(list);
  //
  //   // 2. 해당 주의 모든 날짜를 캐시에 등록 (데이터가 없어도 []로)
  //   for (int i = 0; i < 7; i++) {
  //     final d = startOfWeek.add(Duration(days: i));
  //     final key = _key(studyId, d);
  //     _cache.putIfAbsent(key, () => []);
  //     if (pushToStream && _streams.containsKey(key)) {
  //       _streams[key]!.add(_cache[key]!);
  //     }
  //   }
  //
  //   // 호출자가 요청한 날짜 데이터만 반환
  //   final requestedKey = _key(studyId, date);
  //   _cache.putIfAbsent(requestedKey, () => []);
  //   return _cache[requestedKey] ?? [];
  // }
  //
  // //일별 단일 호출
  // Future<List<ChecklistItemDetailResponse>> _fetchDay(int studyId, DateTime date, {bool pushToStream = true}) async {
  //   log("cache에서 체크리스트 데이터를 찾을 수 없습니다. fetch from server 동작");
  //   final key = _key(studyId, date);
  //   final list = await api.getChecklistItemsOfStudyByDay(studyId, date);
  //   _cache[key] = list;
  //   if (pushToStream && _streams.containsKey(key)) _streams[key]!.add(list);
  //   return list;
  // }
  //
  //
  // //받아온 체크리스트 스터디 + 날짜별로 나눠서 캐시에 반영 + 스트림에 흘려보내기
  // void _saveToCacheAndStream(
  //     List<ChecklistItemDetailResponse> items, {
  //       bool pushToStream = true,
  //     }) {
  //   // 날짜별로 그룹핑
  //   final Map<String, List<ChecklistItemDetailResponse>> grouped = {};
  //   for (final item in items) {
  //     final key = _key(item.studyId, item.targetDate);
  //     grouped.putIfAbsent(key, () => []);
  //     grouped[key]!.add(item);
  //   }
  //
  //   // 캐시에 반영 + 스트림에 push
  //   grouped.forEach((key, value) {
  //     _cache[key] = value;
  //     if (pushToStream && _streams.containsKey(key)) {
  //       _streams[key]!.add(value);
  //     }
  //   });
  // }


//--------------------Optimistic Update--------------------//

  // ===========================================================
  // ✏️ CRUD / REORDER
  // ===========================================================
  Future<void> create(int studyId, ChecklistItemCreateRequest request, String studyName) async {
    final dateKey = _dateKey(request.targetDate);
    final tempId = -DateTime.now().millisecondsSinceEpoch;

    final newItem = ChecklistItemDetailResponse(
        id: tempId,
        type: "STUDY",
        studyId: studyId,
        studyName: studyName,
        studyMemberId: request.assigneeId,
        content: request.content,
        targetDate: request.targetDate,
        completed: false,
        orderIndex: (_cache[dateKey]?.length ?? 0),
    );

    _cache.putIfAbsent(dateKey, () => []);
    _cache[dateKey]!.add(newItem);
    _cacheToAllStreams();

    try {
      final created = await teamApi.createChecklistItemOfStudy(request, studyId);
      final idx = _cache[dateKey]!.indexWhere((e) => e.id == tempId);
      if (idx >= 0) _cache[dateKey]![idx] = created;
    } catch (_) {
      _cache[dateKey]!.removeWhere((e) => e.id == tempId);
      _cacheToAllStreams();
      rethrow;
    }
  }

  Future<void> updateContent(int checklistItemId, int studyId, DateTime date, ChecklistItemContentUpdateRequest request) async {
    final key = _dateKey(date);
    final list = _cache[key]!;

    final idx = list.indexWhere((e) => e.id == checklistItemId);
    if(idx < 0) return;

    final oldItem = list[idx];
    final updatedItem = list[idx] = list[idx].copyWith(content: request.content);
    list[idx] = updatedItem;
    _saveToCacheAndStream([updatedItem]);

    try {
      await teamApi.updateChecklistItemContent(checklistItemId, request);
    } catch (_) {
      list[idx] = oldItem;
      _saveToCacheAndStream([oldItem]);
      rethrow;
    }
  }

  Future<void> toggleStatus(int checklistItemId, int studyId, DateTime date) async {
    final key = _dateKey(date);
    final list = _cache[key]!;
    final idx = list.indexWhere((e) => e.id == checklistItemId);
    if(idx < 0) return;

    final oldItem = list[idx];
    final updatedItem = list[idx] = list[idx].copyWith(completed: !oldItem.completed);
    _saveToCacheAndStream([updatedItem]);

    try {
      await teamApi.updateChecklistItemStatus(checklistItemId);
    } catch (_) {
      list[idx] = oldItem;
      _saveToCacheAndStream([oldItem]);
      rethrow;
    }
  }

  Future<void> softDelete(int checklistItemId, int studyId, DateTime date) async {
    final key = _dateKey(date);
    final list = _cache[key]!;
    final idx = list.indexWhere((e) => e.id == checklistItemId);
    if (idx < 0) return;

    final removedItem = list[idx];
    list.removeAt(idx);
    _saveToCacheAndStream(list);

    try {
      await teamApi.softDeleteChecklistItems(checklistItemId);
    } catch (_) {
      list.insert(idx, removedItem);
      _saveToCacheAndStream(list);
      rethrow;
    }
  }

  Future<void> reorder(List<ChecklistItemReorderRequest> requests, int studyId, DateTime date) async {
    final key = _dateKey(date);
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
    _saveToCacheAndStream(list);
    try {
      await teamApi.reorderChecklistItem(requests);
    } catch (_) {
      _cache[key] = oldList;
      _saveToCacheAndStream(oldList);
      rethrow;
    }
  }
}