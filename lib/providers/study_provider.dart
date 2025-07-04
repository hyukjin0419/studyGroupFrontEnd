import 'package:flutter/material.dart';
import 'package:study_group_front_end/dto/study/create/study_create_request.dart';
import 'package:study_group_front_end/dto/study/detail/my_study_list_response.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/dto/study/detail/study_list_response.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';
import 'package:study_group_front_end/service/study_api_service.dart';

class StudyProvider with ChangeNotifier, LoadingNotifier {
  final StudyApiService studyApiService;

  StudyProvider({required this.studyApiService});

  List<MyStudyListResponse> _studies = [];
  MyStudyListResponse? _selectedStudy;


  List<MyStudyListResponse> get studies => _studies;
  MyStudyListResponse? get selectedStudy => _selectedStudy;

  Future<void> createStudy(StudyCreateRequest request) async {
    await runWithLoading(() async {
      final response = await studyApiService.createStudy(request);
      // await fetchStudies();
      // await fetchStudyDetail(response.id);
    });
  }


  Future<void> fetchStudies() async {
    await runWithLoading(() async {
      _studies = await studyApiService.getMyStudies();
    });
  }
  //
  // Future<void> fetchStudiesByMemberId(int memberId) async {
  //   await runWithLoading(() async {
  //     _studies = await apiService.getStudiesByMemberId(memberId);
  //   });
  // }
  //
  // Future<void> fetchStudyDetail(int id) async {
  //   await runWithLoading(() async {
  //     _selectedStudy = await apiService.getStudyById(id);
  //   });
  // }
  //
  //
  //
  // Future<void> updateStudy(int studyId, int leaderId, StudyUpdateRequest request) async {
  //   await runWithLoading(() async {
  //     await apiService.updateStudy(studyId, leaderId, request);
  //     await fetchStudies();
  //     await fetchStudyDetail(studyId);
  //   });
  // }
  //
  // Future<void> deleteStudy(int studyId, int leaderId) async {
  //   await runWithLoading(() async {
  //     await apiService.deleteStudy(studyId, leaderId);
  //     await fetchStudies();
  //     _selectedStudy = null;
  //   });
  // }
}
