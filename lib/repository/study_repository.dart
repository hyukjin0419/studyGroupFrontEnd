import 'dart:developer';

import 'package:study_group_front_end/api_service/study_api_service.dart';
import 'package:study_group_front_end/dto/study/create/study_create_request.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/dto/study/update/study_order_update_request.dart';
import 'package:study_group_front_end/dto/study/update/study_update_request.dart';

class StudyRepository {
  final StudyApiService api;
  StudyRepository(this.api);

  Future<void> createStudy(StudyCreateRequest request) {
    return api.createStudy(request);
  }

  Future<List<StudyDetailResponse>> fetchMyStudies(){
    return api.getMyStudies();
  }

  Future<StudyDetailResponse> fetchMyStudy(int studyId){
    return api.getMyStudy(studyId);
  }

  Future<StudyDetailResponse> updateStudy(StudyUpdateRequest request){
    return api.updateStudy(request);
  }

  Future<void> deleteStudy(int studyId) {
    return api.deleteStudy(studyId);
  }

  Future<void> leaveStudy(int studyId) {
    return api.leaveStudy(studyId);
  }

  Future<void> updateStudiesOrder(List<StudyOrderUpdateRequest> request) {
    return api.updateStudiesOrder(request);
  }
}