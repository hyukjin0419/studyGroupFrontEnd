import 'package:flutter/material.dart';
import '../models/study.dart';
import '../mock/mock_studies.dart';

class StudyProvider extends ChangeNotifier {
  final List<Study> _studies = [...mockStudies];

  List<Study> get studies => _studies;

  void addStudy(Study study){
    _studies.add(study);
    notifyListeners();
  }

  void removeStudy(int id){
    _studies.removeWhere((s) => s.id == id);
    notifyListeners();
  }
}