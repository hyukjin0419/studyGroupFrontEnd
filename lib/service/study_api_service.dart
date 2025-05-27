import 'dart:convert';
import 'package:study_group_front_end/models/study.dart';
import 'package:study_group_front_end/service/base_api_service.dart';

class StudyApiService extends BaseApiService {
  final String basePath = '/studies';

  StudyApiService({
    required super.baseUrl,
    super.client,
  });

  Future<StudyCreateResDto> createStudy(StudyCreateReqDto request) async {
    final response = await httpClient.post(
      uri(basePath, ''),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return StudyCreateResDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('create Study failed: ${response.statusCode}');
    }
  }

  Future<StudyDetailResDto> getStudyById(int id) async {
    final response = await httpClient.get(uri(basePath, "/$id"));

    if (response.statusCode == 200) {
      return StudyDetailResDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('create Study failed: ${response.statusCode}');
    }
  }

  Future<List<StudyListResDto>> getStudiesByMemberId(int memberId) async {
    final response = await httpClient.get(uri('/members/', '$memberId/studies'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = decodeJson(response);
      return jsonList.map((e) => StudyListResDto.fromJson(e)).toList();
    } else {
      throw Exception('create Study failed: ${response.statusCode}');
    }
  }

  Future<List<StudyListResDto>> getAllStudies() async {
    final response = await httpClient.get(uri(basePath, ''));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = decodeJson(response);
      return jsonList.map((e) => StudyListResDto.fromJson(e)).toList();
    } else {
      throw Exception('create Study failed: ${response.statusCode}');
    }
  }

  Future<StudyUpdateResDto> updateStudy(int studyId, int leaderId, StudyUpdateReqDto request) async {
    final response = await httpClient.post(
      uri(basePath, '/$studyId'),
      headers: {
        'Content-Type': 'application/json',
        'X-Leader_id': leaderId.toString(),
      },
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return StudyUpdateResDto.fromJson(decodeJson(response));
    } else {
      throw Exception('update study failed: ${response.statusCode}');
    }
  }

  Future<StudyDeleteResDto> deleteStudy(int studyId, int leaderId) async {
    final response = await httpClient.delete(
      uri(basePath, '/$studyId'),
      headers: {
        'X-Leader_Id': leaderId.toString(),
      },
    );

    if (response.statusCode == 200) {
      return StudyDeleteResDto.fromJson(decodeJson(response));
    } else {
      throw Exception('delete study failed: ${response.statusCode}');
    }
  }
}
