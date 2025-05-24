import 'dart:convert';
import 'package:study_group_front_end/models/checklist.dart';
import 'package:study_group_front_end/service/base_api_service.dart';

class ChecklistApiService extends BaseApiService {
  final String basePath = '/checklist';

  ChecklistApiService({
    required super.baseUrl,
    super.client,
  });

  Future<ChecklistCreateResDto> createChecklist(
      int creatorId, ChecklistCreateReqDto request) async {
    final response = await httpClient.post(
      uri(basePath, ''),
      headers: {
        'Content-Type': 'application/json',
        'X-Member-Id': creatorId.toString(),
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return ChecklistCreateResDto.fromJson(decodeJson(response));
    } else {
      throw Exception('create checklist failed: ${response.statusCode}');
    }
  }

  Future<void> updateContent(int checklistId, String content) async {
    final response = await httpClient.post(
      uri(basePath, '/$checklistId/content'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode != 200) {
      throw Exception('update content failed: ${response.statusCode}');
    }
  }

  Future<void> updateDueDate(int checklistId, DateTime dueDate) async {
    final response = await httpClient.post(
      uri(basePath, '/$checklistId/duedate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'dueDate': dueDate.toIso8601String()}),
    );

    if (response.statusCode != 200) {
      throw Exception('update due date failed: ${response.statusCode}');
    }
  }

  Future<ChecklistDetailResDto> getChecklistDetail(int checklistId) async {
    final response = await httpClient.get(
      uri(basePath, '/$checklistId'),
    );

    if (response.statusCode == 200) {
      return ChecklistDetailResDto.fromJson(decodeJson(response));
    } else {
      throw Exception('get checklist failed: ${response.statusCode}');
    }
  }

  Future<ChecklistDeleteResDto> deleteChecklist(int checklistId) async {
    final response = await httpClient.delete(
      uri(basePath, '/$checklistId'),
    );

    if (response.statusCode == 200) {
      return ChecklistDeleteResDto.fromJson(decodeJson(response));
    } else {
      throw Exception('delete checklist failed: ${response.statusCode}');
    }
  }
}
