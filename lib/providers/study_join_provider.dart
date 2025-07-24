import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:study_group_front_end/api_service/study_join_api_service.dart';
import 'package:study_group_front_end/dto/study_member/fellower/study_join_request.dart';
import 'package:study_group_front_end/dto/study_member/leader/study_join_code_response.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';

class StudyJoinProvider with ChangeNotifier, LoadingNotifier {
  final StudyJoinApiService studyJoinApiService;

  StudyJoinProvider(this.studyJoinApiService);

  StudyJoinCodeResponse? _joinCodeResponse;

  Future<void> getStudyJoinCode(int studyId) async {
    log("getStudyJoinCode", name: "study_join_provider");
    await runWithLoading(() async {
      _joinCodeResponse = await studyJoinApiService.getStudyJoinCode(studyId);
    });
  }

  Future<void> join(StudyJoinRequest request) async {
    log("join Study by Code", name: "study_join_provider");
    await runWithLoading(() async {
      await studyJoinApiService.join(request);
    });
  }
}