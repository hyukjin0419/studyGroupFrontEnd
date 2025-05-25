import 'package:flutter/material.dart';
import 'package:study_group_front_end/models/study.dart';
import 'package:study_group_front_end/service/study_api_service.dart';

class StudyProvicder with ChangeNotifier {
  final StudyApiService apiService;

  StudyProvicder({required this.apiService});

  List<StudyListResDto> _studies = [];
  StudyDetailResDto? _selectedStudy;
  bool _isLoading = false;

  List<StudyListResDto> get studies => _studies;
  StudyDetailResDto? get selectedStudy => _selectedStudy;
  bool get isLoading => _isLoading;

  Future<void> fetchStudies() async {
    _setLoading(true);
    try{
      _studies = await apiService.getAllStudies();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchStudyDetail(int id) async {
    _setLoading(true);
    try {
      _selectedStudy = await apiService.getStudyById(id);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createStudy(StudyCreateReqDto request) async {
    _setLoading(true);
    try {
      final response = await apiService.createStudy(request);
      await fetchStudies();
      await fetchStudyDetail(response.id);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateStudy(int studyId, int leaderId, StudyUpdateReqDto request) async {
    _setLoading(true);
    try {
      await apiService.updateStudy(studyId, leaderId, request);
      await fetchStudies();
      await fetchStudyDetail(studyId);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteStudy(int studyId, int leaderId) async {
    _setLoading(true);
    try {
      await apiService.deleteStudy(studyId, leaderId);
      await fetchStudies();
      _selectedStudy = null;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }
}
