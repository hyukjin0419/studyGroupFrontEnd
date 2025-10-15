import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:study_group_front_end/api_service/personal_checklist_api_service.dart';
import 'package:study_group_front_end/dto/personal_checklist/personal_checklist_detail_response.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';

class PersonalChecklistProvider with ChangeNotifier, LoadingNotifier {
  final PersonalChecklistApiService api;
  PersonalChecklistProvider(this.api);

  List<PersonalChecklistDetailResponse> _personalChecklists = [];
  List<PersonalChecklistDetailResponse> get personalChecklists => _personalChecklists;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;
  void updateSelectedDate(DateTime newDate) {
    _selectedDate = newDate;
    notifyListeners();
  }


  Future<void> fetchPersonalChecklists() async {
    log("호출");
    await runWithLoading(() async{
      _personalChecklists = await api.getChecklistItemsOfStudyByWeek(_selectedDate);
    });

  }
}