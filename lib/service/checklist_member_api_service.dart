import 'dart:convert';
import 'package:study_group_front_end/models/checklist_member.dart';
import 'package:study_group_front_end/service/base_api_service.dart';

class ChecklistMemberApiService extends BaseApiService{
  final String basePath = '/checklist-members';

  ChecklistMemberApiService({
    required super.baseUrl,
    super.client,
  });


  Future<ChecklistMemberAssignResDto> assignChecklist(ChecklistMemberAssignReqDto request) async {
    final response = await httpClient.post(
        uri(baseUrl, '/assign'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return ChecklistMemberAssignResDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("assignChecklist 실패: ${response.statusCode}");
    }
  }

  Future<ChecklistMemberChangeStatusResDto> changeChecklistStatus(ChecklistMemberAssignReqDto request) async {
    final response = await httpClient.post(
      uri(baseUrl, '/change-status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return ChecklistMemberChangeStatusResDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("change checklist status 실패: ${response.statusCode}");
    }
  }

  Future<ChecklistMemberUnassignResDto> unassignChecklist(int checklistId, int memberId) async{
    final response = await httpClient.delete(
      uri(baseUrl, '/$checklistId/members/$memberId'),
    );

    if (response.statusCode == 200) {
      return ChecklistMemberUnassignResDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("unassign checklist 실패: ${response.statusCode}");
    }
  }

  Future<List<ChecklistMemberResDto>> getChecklistsByMemberId(int memberId) async {
    final response = await httpClient.get(uri(baseUrl, '/member/$memberId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((e) => ChecklistMemberResDto.fromJson(e)).toList();
    } else {
      throw Exception("checklist by member Id 조회 실패: ${response.statusCode}");
    }
  }

  Future<List<StudyChecklistMemberResDto>> getChecklistByStudyId(int studyId) async{
    final response = await httpClient.get(uri(baseUrl,'/study/$studyId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((e) => StudyChecklistMemberResDto.fromJson(e)).toList();
    } else {
      throw Exception("checklist by study Id 조회 실패: ${response.statusCode}");
    }
  }
}