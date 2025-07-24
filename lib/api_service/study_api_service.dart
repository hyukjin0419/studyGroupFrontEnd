import 'dart:convert';

import 'package:study_group_front_end/dto/study/create/study_create_request.dart';
import 'package:study_group_front_end/dto/study/create/study_create_response.dart';
import 'package:study_group_front_end/dto/study/delete/study_delete_response.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/dto/study/update/study_order_update_request.dart';
import 'package:study_group_front_end/dto/study/update/study_update_request.dart';
import 'package:study_group_front_end/api_service/base_api_service.dart';

class StudyApiService extends BaseApiService {
  final String basePath = '/studies';

  Future<StudyCreateResponse> createStudy(StudyCreateRequest request) async {
    final response = await post(
      '$basePath/create',
      request.toJson()
    );

    if (response.statusCode == 200) {
      return StudyCreateResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('[USER] STUDY_API createStudy_본인이 속한 스터디 생성 실패: ${response.statusCode}');
    }
  }

  Future<List<StudyDetailResponse>> getMyStudies() async {
    final response = await get(basePath);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((e) => StudyDetailResponse.fromJson(e)).toList();
      } else {
        throw Exception('[USER] STUDY_API getMyStudies_본인이 속한 스터디 리스트 조회 실패: ${response.statusCode}');
      }
  }

  Future<StudyDetailResponse> getMyStudy(int studyId) async {
    final response = await get(
      '$basePath/$studyId'
    );

    if (response.statusCode == 200) {
      return StudyDetailResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('[USER] STUDY_API getMyStudy_본인이 속한 스터디 단일 조회 실패: ${response.statusCode}');
    }
  }

  Future<StudyDetailResponse> updateStudy(StudyUpdateRequest request) async {
    final response = await post(
      '$basePath/update',
      request.toJson()
    );

    if (response.statusCode == 200) {
      return StudyDetailResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('[USER] STUDY_API updateStudy_본인 속한 단일 스터디 업데이트 실패: ${response.statusCode}');
    }
  }

  Future<void> updateStudiesOrder(List<StudyOrderUpdateRequest> request) async {
    final body = request.map((e) => e.toJson()).toList();

    final response = await post(
      '$basePath/update-order',
      body
    );

    if (response.statusCode != 200) {
      throw Exception(
          '[USER] STUDY_API updateStudiesOrder_본인 속한 스터디 순서 업데이트 (Drag & Drop) 실패: ${response
              .statusCode}');
    }
  }

  Future<StudyDeleteResponse> deleteStudy(int studyId) async {
    final response = await delete(
      '$basePath/delete/$studyId',
    );

    if (response.statusCode == 200) {
      return StudyDeleteResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('[USER] STUDY_API deleteStudy_리더로써 스터디 삭제 실패: ${response.statusCode}');
    }
  }
}
