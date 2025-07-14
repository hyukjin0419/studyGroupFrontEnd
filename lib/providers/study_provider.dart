import 'package:flutter/material.dart';
import 'package:study_group_front_end/dto/study/create/study_create_request.dart';
import 'package:study_group_front_end/dto/study/detail/my_study_list_response.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/dto/study/update/study_order_update_request.dart';
import 'package:study_group_front_end/dto/study/update/study_update_request.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';
import 'package:study_group_front_end/service/study_api_service.dart';

class StudyProvider with ChangeNotifier, LoadingNotifier {
  final StudyApiService studyApiService;

  StudyProvider(this.studyApiService);

  List<StudyDetailResponse> _studies = [];
  StudyDetailResponse? _selectedStudy;


  List<StudyDetailResponse> get studies => _studies;
  StudyDetailResponse? get selectedStudy => _selectedStudy;

  Future<void> createStudy(StudyCreateRequest request) async {
    debugPrint("createStudy");
    await runWithLoading(() async {
      await studyApiService.createStudy(request);
      await getMyStudies();
    });
  }

  Future<void> getMyStudies() async {
    debugPrint("getMyStudies");
    await runWithLoading(() async {
      _studies = await studyApiService.getMyStudies();
    });
  }

  Future<void> getMyStudy(int studyId) async {
    await runWithLoading(() async {
      _selectedStudy = await studyApiService.getMyStudy(studyId);
    });
  }

  Future<void> updateStudy(StudyUpdateRequest request) async {
    await runWithLoading(() async{
      _selectedStudy = await studyApiService.updateStudy(request);
    });
  }

  Future<void> deleteStudy(int studyId) async {
    await runWithLoading(() async {
      await studyApiService.deleteStudy(studyId);
    });
  }

  //--------------------스터디 drag & drop ------------------------------------//
  //화면에서 먼저 업데이트
  void reorderStudies(int oldIndex, int newIndex) {
    debugPrint("reorderStudies");

    //if (oldIndex < newIndex) newIndex -= 1;
    final item = _studies.removeAt(oldIndex);
    _studies.insert(newIndex, item);
    notifyListeners();
  }

  //이후 백쪽에 반영
  Future<void> updateStudiesOrder() async {
    final request = _studies
      .asMap()
      .entries
      .map((study) => StudyOrderUpdateRequest(
        studyId: study.value.id, personalOrderIndex: study.key
    )).toList();

    try {
      await studyApiService.updateStudiesOrder(request);
      _studies= await studyApiService.getMyStudies();
      notifyListeners();
    } catch (e) {
      debugPrint("[Provider] updateStudiesOrder 실패: $e");
    }
  }
}
