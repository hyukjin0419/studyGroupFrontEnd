import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:study_group_front_end/models/checklist_member.dart';
import 'package:study_group_front_end/models/member.dart';
import 'package:study_group_front_end/service/base_api_service.dart';

class  MemberApiService extends BaseApiService{
  final String basePath = '/members';

  MemberApiService({
    required super.baseUrl,
    super.client,
  });

  Future<MemberCreateResDto> createMember(MemberCreateReqDto request) async {
    final response = await httpClient.post(
      uri(basePath,''),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return MemberCreateResDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('create Member failed: ${response.statusCode}');
    }
  }

  Future<MemberLoginResDto> login(MemberLoginReqDto request) async {
    final response = await httpClient.post(
      uri(basePath, '/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return MemberLoginResDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('login failed: ${response.statusCode}');
    }
  }

  Future<MemberDetailResDto> getMemberById(int id) async {
    final response = await httpClient.get(
      uri(basePath, '/$id'),
    );

    if (response.statusCode == 200) {
      return MemberDetailResDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('get member by id failed: ${response.statusCode}');
    }
  }

  Future<List<MemberDetailResDto>> getAllMembers() async {
    final response = await httpClient.get(
      uri(basePath, ''),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((e) => MemberDetailResDto.fromJson(e)).toList();
    } else {
      throw Exception('get all members failed: ${response.statusCode}');
    }
  }

  Future<MemberDetailResDto> updateMember(MemberUpdateReqDto request) async {
    final response = await httpClient.post(
      uri(basePath, '/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return MemberDetailResDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('update member failed: ${response.statusCode}');
    }
  }

  Future<MemberDeleteResDto> deleteMember(int id) async{
    final response = await httpClient.delete(uri(basePath,'$id'));

    if (response.statusCode == 200) {
      return MemberDeleteResDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('delete member failed: ${response.statusCode}');
    }
  }
  /*


  1. delete dto 프론트단에서 바꾸고
  2. 이거 바꿔
   */
}
