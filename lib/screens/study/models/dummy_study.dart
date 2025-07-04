// study/models/dummy_study.dart
import 'package:flutter/material.dart';

class Study {
  final String title;
  final double progress;
  final String dDay;
  final String status;
  final Color color;

  Study({
    required this.title,
    required this.progress,
    required this.dDay,
    required this.status,
    required this.color,
  });
}

final dummyStudyList = [
  Study(title: '캡스톤시각디자인1', progress: 0.78, dDay: 'D-19', status: '진행중', color: Colors.red.shade300),
  Study(title: '편집디자인3', progress: 0.93, dDay: 'D-8', status: '진행중', color: Colors.red.shade300),
  Study(title: '파이썬 프로젝트', progress: 1.0, dDay: 'D-13', status: '완료', color: Colors.orange.shade400),
  Study(title: '카페창업준비', progress: 0.32, dDay: 'D-65', status: '진행중', color: Colors.yellow.shade600),
  Study(title: '사회복지개론', progress: 0.0, dDay: 'D-415', status: '준비중', color: Colors.green.shade300),
  Study(title: 'AI 프로젝트 특별반', progress: 0.0, dDay: 'D-365', status: '준비중', color: Colors.green.shade300),
  Study(title: '세계여행플랜', progress: 1.0, dDay: 'D-0', status: '완료', color: Colors.blue.shade400),
];
