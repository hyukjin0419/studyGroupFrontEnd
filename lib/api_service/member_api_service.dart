import 'dart:convert';
import 'package:study_group_front_end/api_service/base_api_service.dart';
import 'package:study_group_front_end/dto/member/delete/member_delete_response.dart';
import 'package:study_group_front_end/dto/member/detail/member_detail_response.dart';
import 'package:study_group_front_end/dto/member/search/member_search_request.dart';
import 'package:study_group_front_end/dto/member/search/member_search_response.dart';
import 'package:study_group_front_end/dto/member/update/member_update_request.dart';

class  MemberApiService extends BaseApiService{
  final String basePath = '/members';

  Future<List<MemberSearchResponse>> searchMembers(MemberSearchRequest request) async {
    final response = await get(
        '$basePath/${request.studyId}/search?keyword=${Uri.encodeQueryComponent(request.keyword)}',
    );

    if (response.statusCode == 200){
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((e) => MemberSearchResponse.fromJson(e)).toList();
    } else {
      throw Exception('[USER] MEMBER_API searchMembers_사용자 이름 일부로 멤버 검색 실패: ${response.statusCode}');
    }
  }
}
