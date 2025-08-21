import 'dart:convert';

import 'package:study_group_front_end/api_service/base_api_service.dart';

import 'package:study_group_front_end/dto/checklist_item/create/checklist_item_create_request.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/dto/checklist_item/update/checklist_item_content_update_request.dart';

class ChecklistItemApiService extends BaseApiService {
  final String basePath = '/studies';

  Future<void> createChecklistItemOfStudy(ChecklistItemCreateRequest request, int studyId) async {
    final response = await post(
      '$basePath/$studyId/checklistItem/create',
      request.toJson()
    );

    if (response.statusCode != 200) {
      throw Exception(
          '[Checklist_Item_API_Service] createChecklistItemOfStudy 실패: ${response.statusCode}'
      );
    }
  }

  Future<List<ChecklistItemDetailResponse>> getChecklistItemsOfStudy(int studyId, DateTime targetDate) async{
    final formattedDate = targetDate.toIso8601String().split("T").first;

    final response = await get(
      '$basePath/$studyId/checklists?targetDate=$formattedDate'
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((e) => ChecklistItemDetailResponse.fromJson(e)).toList();
    } else{
      throw Exception('[Checklist_Item_API_Service] getChecklistItemsOfStudy 실패: ${response.statusCode}');
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
}
// class ChecklistApiService extends BaseApiService {
//   final String basePath = '/checklist';
//
//   ChecklistApiService({
//     required super.baseUrl,
//     super.client,
//   });
//
//   Future<ChecklistCreateResDto> createChecklist(
//       int creatorId, ChecklistCreateReqDto request) async {
//     final response = await httpClient.post(
//       uri(basePath, ''),
//       headers: {
//         'Content-Type': 'application/json',
//         'X-Member-Id': creatorId.toString(),
//       },
//       body: jsonEncode(request.toJson()),
//     );
//
//     if (response.statusCode == 200) {
//       return ChecklistCreateResDto.fromJson(decodeJson(response));
//     } else {
//       throw Exception('create checklist failed: ${response.statusCode}');
//     }
//   }
//
//   Future<void> updateContent(int checklistId, String content) async {
//     final response = await httpClient.post(
//       uri(basePath, '/$checklistId/content'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'content': content}),
//     );
//
//     if (response.statusCode != 200) {
//       throw Exception('update content failed: ${response.statusCode}');
//     }
//   }
//
//   Future<void> updateDueDate(int checklistId, DateTime dueDate) async {
//     final response = await httpClient.post(
//       uri(basePath, '/$checklistId/duedate'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'dueDate': dueDate.toIso8601String()}),
//     );
//
//     if (response.statusCode != 200) {
//       throw Exception('update due date failed: ${response.statusCode}');
//     }
//   }
//
//   Future<ChecklistDetailResDto> getChecklistDetail(int checklistId) async {
//     final response = await httpClient.get(
//       uri(basePath, '/$checklistId'),
//     );
//
//     if (response.statusCode == 200) {
//       return ChecklistDetailResDto.fromJson(decodeJson(response));
//     } else {
//       throw Exception('get checklist failed: ${response.statusCode}');
//     }
//   }
//
//   Future<ChecklistDeleteResDto> deleteChecklist(int checklistId) async {
//     final response = await httpClient.delete(
//       uri(basePath, '/$checklistId'),
//     );
//
//     if (response.statusCode == 200) {
//       return ChecklistDeleteResDto.fromJson(decodeJson(response));
//     } else {
//       throw Exception('delete checklist failed: ${response.statusCode}');
//     }
//   }
// }
