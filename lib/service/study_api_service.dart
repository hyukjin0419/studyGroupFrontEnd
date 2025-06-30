import 'dart:convert';
import 'package:study_group_front_end/dto/study/create/study_create_request.dart';
import 'package:study_group_front_end/dto/study/create/study_create_response.dart';
import 'package:study_group_front_end/dto/study/delete/study_delete_response.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/dto/study/detail/study_list_response.dart';
import 'package:study_group_front_end/dto/study/update/study_update_request.dart';
import 'package:study_group_front_end/service/base_api_service.dart';

class StudyApiService extends BaseApiService {
  final String basePath = '/studies';

  Future<StudyCreateResponse> createStudy(StudyCreateRequest request) async {
    final response = await post(
      basePath,
      request.toJson()
    );

    if (response.statusCode == 200) {
      return StudyCreateResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('create Study failed: ${response.statusCode}');
    }
  }

  Future<StudyDetailResponse> updateStudy(int studyId, StudyUpdateRequest request) async {
    final response = await post(
      '$basePath/$studyId',
      request.toJson()
    );

    if (response.statusCode == 200) {
      return StudyDetailResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('update study failed: ${response.statusCode}');
    }
  }

  Future<StudyDeleteResponse> deleteStudy(int studyId) async {
    final response = await delete('$basePath/$studyId');

    if (response.statusCode == 200) {
      return StudyDeleteResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('delete study failed: ${response.statusCode}');
    }
  }

  //------------------------관리자용 (일단 안씀)----------------------------------//
  Future<StudyDetailResponse> getStudyById(int studyId) async {
    final response = await get('basePath/$studyId');

    if (response.statusCode == 200) {
      return StudyDetailResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('get study failed: ${response.statusCode}');
    }
  }

  Future<List<StudyListResponse>> getAllStudies() async {
    final response = await get(basePath);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((e) => StudyListResponse.fromJson(e)).toList();
    } else {
      throw Exception('get all studies failed: ${response.statusCode}');
    }
  }
}
