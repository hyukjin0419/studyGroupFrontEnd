import 'package:flutter/material.dart';
import 'package:study_group_front_end/models/study.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';
import 'package:study_group_front_end/service/study_api_service.dart';

class StudyProvider with ChangeNotifier, LoadingNotifier {
  final StudyApiService apiService;

  StudyProvider({required this.apiService});

  List<StudyListResDto> _studies = [];
  StudyDetailResDto? _selectedStudy;


  List<StudyListResDto> get studies => _studies;
  StudyDetailResDto? get selectedStudy => _selectedStudy;


  //memberId로 fetch하는거 추가해야겠네
  Future<void> fetchStudies() async {
    await runWithLoading(() async {
      _studies = await apiService.getAllStudies();
    });
  }

  Future<void> fetchStudiesByMemberId(int memberId) async {
    await runWithLoading(() async {
      _studies = await apiService.getStudiesByMemberId(memberId);
    });
  }

  Future<void> fetchStudyDetail(int id) async {
    await runWithLoading(() async {
      _selectedStudy = await apiService.getStudyById(id);
    });
  }

  Future<void> createStudy(StudyCreateReqDto request) async {
    await runWithLoading(() async {
      final response = await apiService.createStudy(request);
      await fetchStudies();
      await fetchStudyDetail(response.id);
    });
  }

  Future<void> updateStudy(int studyId, int leaderId, StudyUpdateReqDto request) async {
    await runWithLoading(() async {
      await apiService.updateStudy(studyId, leaderId, request);
      await fetchStudies();
      await fetchStudyDetail(studyId);
    });
  }

  Future<void> deleteStudy(int studyId, int leaderId) async {
    await runWithLoading(() async {
      await apiService.deleteStudy(studyId, leaderId);
      await fetchStudies();
      _selectedStudy = null;
    });
  }
}
