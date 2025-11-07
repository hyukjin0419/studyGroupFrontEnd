import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:study_group_front_end/api_service/study_api_service.dart';
import 'package:study_group_front_end/dto/study/create/study_create_request.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/dto/study/update/study_order_update_request.dart';
import 'package:study_group_front_end/dto/study/update/study_update_request.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';

class StudyProvider with ChangeNotifier, LoadingNotifier {
  final StudyApiService api;
  StudyProvider(this.api);

  List<StudyDetailResponse> _studies = [];
  StudyDetailResponse? _selectedStudy;

  List<StudyDetailResponse> get studies => _studies;
  StudyDetailResponse? get selectedStudy => _selectedStudy;

  //--------------------Read--------------------//
  Future<void> getMyStudies() async {
    await runWithLoading(() async {
      _studies = await api.getMyStudies();
    });
  }

  Future<void> getMyStudy(int studyId) async {
    await runWithLoading(() async {
      _selectedStudy = await api.getMyStudy(studyId);
    });
  }

  //---------------Create/Update---------------//
  Future<void> createStudy(StudyCreateRequest request) async {
    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final temp = StudyDetailResponse(
        id: tempId,
        name: request.name,
        description: request.description,
        leaderId: 0,
        leaderName: '',
        joinCode: '',
        personalColor: request.color,
        dueDate: request.dueDate,
        status: '',
        members: const[]
    );

    _studies = [..._studies, temp];
    notifyListeners();

    try {
      await runWithLoading(() async {
        await api.createStudy(request);
        _studies = await api.getMyStudies();
      });
      notifyListeners();
    } catch (e) {
      log("createStudy 실패: $e\nRoll back 합니다.", name: "[Study Provider]");
      _studies.removeWhere((s) => s.id == tempId);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateStudy(StudyUpdateRequest request) async {
    final idx = _studies.indexWhere((s) => s.id == request.studyId);
    if (idx == -1) return;

    final prev = _studies[idx];
    final optimistic = _copyUpdated(prev, request);
    _studies[idx] = optimistic;
    if (_selectedStudy?.id == request.studyId) {
      _selectedStudy = optimistic;
    }

    try {
      await runWithLoading(() async {
        final updated = await api.updateStudy(request);
        _studies[idx] = updated;
        if (_selectedStudy?.id == request.studyId) {
          _selectedStudy = updated;
        }

        // _studies = await repository.fetchMyStudies();
        // _selectedStudy = await repository.fetchMyStudy(request.studyId);
      });
      notifyListeners();
    } catch (e) {
      log("updateStudy 실패: $e\nRoll back 합니다.", name: "[Study Provider]");
      _studies[idx] = prev;
      if (_selectedStudy?.id == request.studyId) {
        _selectedStudy = prev;
      }
      notifyListeners();
      rethrow;
    }
  }

  StudyDetailResponse _copyUpdated(StudyDetailResponse prev, StudyUpdateRequest req) {
    return StudyDetailResponse(
        id: prev.id,
        name: req.name,
        description: prev.description,
        leaderId: prev.leaderId,
        leaderName: prev.leaderName,
        joinCode: prev.joinCode,
        personalColor: req.personalColor,
        dueDate: req.dueDate,
        status: prev.status,
        members: prev.members);
  }

//---------------Delete---------------//
  Future<void> deleteStudy(int studyId) async{
    //shallow copy
    final prev = List<StudyDetailResponse>.from(_studies);
    _studies.removeWhere((s) => s.id == studyId);
    notifyListeners();

    try{
      await api.deleteStudy(studyId);
      _studies = await api.getMyStudies();
      notifyListeners();
    } catch (e) {
      log("deleteStudy 실패: $e\nRoll back 합니다.", name: "[Study Provider]");
      _studies = prev;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateStudiesOrder(int oldIndex, int newIndex) async {
    final prev = List<StudyDetailResponse>.from(_studies);
    final item = _studies.removeAt(oldIndex);
    _studies.insert(newIndex, item);
    notifyListeners();

    final request = _studies
        .asMap()
        .entries
        .map((study) => StudyOrderUpdateRequest(
        studyId: study.value.id, personalOrderIndex: study.key
    )).toList();

    try {
      await api.updateStudiesOrder(request);
      _studies= await api.getMyStudies();
      notifyListeners();
    } catch (e) {
      log("deleteStudy 실패: $e\nRoll back 합니다.", name: "[Study Provider]");
      _studies = prev;
      notifyListeners();
      rethrow;
    }
  }

  //---------------Leave---------------//
  Future<void> leaveStudy(int studyId) async{
    //shallow copy
    final prev = List<StudyDetailResponse>.from(_studies);
    _studies.removeWhere((s) => s.id == studyId);
    notifyListeners();

    try{
      await api.leaveStudy(studyId);
      _studies = await api.getMyStudies();
      notifyListeners();
    } catch (e) {
      log("deleteStudy 실패: $e\nRoll back 합니다.", name: "[Study Provider]");
      _studies = prev;
      notifyListeners();
      rethrow;
    }
  }
}
