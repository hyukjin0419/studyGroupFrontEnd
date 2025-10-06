import 'dart:convert';

import 'package:study_group_front_end/api_service/base_api_service.dart';

import 'package:study_group_front_end/dto/checklist_item/create/checklist_item_create_request.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/dto/checklist_item/update/checklist_item_content_update_request.dart';
import 'package:study_group_front_end/dto/checklist_item/update/checklist_item_reorder_request.dart';

class ChecklistItemApiService extends BaseApiService {
  final String basePath = '/studies';

  Future<ChecklistItemDetailResponse> createChecklistItemOfStudy(ChecklistItemCreateRequest request, int studyId) async {
    final response = await post(
      '$basePath/$studyId/checklistItem/create',
      request.toJson()
    );

    if (response.statusCode == 200) {
      return ChecklistItemDetailResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('[Checklist_Item_API_Service] createChecklistItemOfStudy 실패: ${response.statusCode}');
    }
  }

  Future<List<ChecklistItemDetailResponse>> prefetchChecklistItems() async {
    final response = await get(
        '$basePath/me/checklists/prefetch'
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((e) => ChecklistItemDetailResponse.fromJson(e)).toList();
    } else{
      throw Exception('[Checklist_Item_API_Service] prefetchChecklistItems 실패: ${response.statusCode}');
    }
  }


  Future<List<ChecklistItemDetailResponse>> getChecklistItemsOfStudyByDay(int studyId, DateTime startDate) async{
    final formattedDate = startDate.toIso8601String().split("T").first;

    final response = await get(
      '$basePath/$studyId/checklists?targetDate=$formattedDate'
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((e) => ChecklistItemDetailResponse.fromJson(e)).toList();
    } else{
      throw Exception('[Checklist_Item_API_Service] getChecklistItemsOfStudyByDay 실패: ${response.statusCode}');
    }
  }

  Future<List<ChecklistItemDetailResponse>> getChecklistItemsOfStudyByWeek(int studyId, DateTime targetDate) async{
    final formattedDate = targetDate.toIso8601String().split("T").first;

    final response = await get(
      '$basePath/$studyId/checklists/week?startDate=$formattedDate'
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((e) => ChecklistItemDetailResponse.fromJson(e)).toList();
    } else{
      throw Exception('[Checklist_Item_API_Service] getChecklistItemsOfStudyByWeek 실패: ${response.statusCode}');
    }
  }



  Future<void> updateChecklistItemContent(int checklistItemId, ChecklistItemContentUpdateRequest request) async {
    final response = await post(
        '/checklistItem/$checklistItemId',
        request.toJson()
    );

    if (response.statusCode != 200) {
      throw Exception(
          '[Checklist_Item_API_Service] updateChecklistItemContent 실패: ${response.statusCode}'
      );
    }
  }

  Future<void> updateChecklistItemStatus(int checklistItemId) async {
    final response = await post(
        '/checklistItem/$checklistItemId/changeCheckStatus',
        null
    );

    if (response.statusCode != 200) {
      throw Exception(
          '[Checklist_Item_API_Service] updateChecklistItemStatus 실패: ${response.statusCode}'
      );
    }
  }

  Future<void> reorderChecklistItem(List<ChecklistItemReorderRequest> requestList) async {
    final response = await post(
        '/checklistItem/reorder',
        requestList,
    );

    if (response.statusCode != 200) {
      throw Exception(
          '[Checklist_Item_API_Service] reorderChecklistItem 실패: ${response.statusCode}'
      );
    }
  }

  Future<void> softDeleteChecklistItems(int checklistItemId) async {
    final response = await post(
        '/checklistItem/$checklistItemId/delete',
        null
    );

    if (response.statusCode != 200) {
      throw Exception(
          '[Checklist_Item_API_Service] softDeleteChecklistItems 실패: ${response.statusCode}'
      );
    }
  }
}