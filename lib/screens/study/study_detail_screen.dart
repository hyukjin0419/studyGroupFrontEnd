import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/providers/study_provider.dart';

class StudyDetailScreen extends StatefulWidget {
  final int studyId;
  const StudyDetailScreen({super.key, required this.studyId});

  @override
  State<StudyDetailScreen> createState() => _StudyDetailScreenState();
}

class _StudyDetailScreenState extends State<StudyDetailScreen> {
  StudyDetailResponse? study;
  bool _isloading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudy();
    });
  }

  Future<void> _loadStudy() async {
    try {
      final provider = context.read<StudyProvider>();
      await provider.getMyStudy(widget.studyId);

      setState(() {
        study = provider.selectedStudy;
        _isloading = false;
      });
    } catch (e) {
      log("스터디 불러오기 실패: $e", name: "Study Detail Screen");
      setState(() => _isloading = false);
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => GoRouter.of(context).pop(),
          ),
          title: Text('${study?.name}')),
      body: _isloading
        ? const Center(child: Text("스터디 상세"))
        : study == null
          ? const Center(child: Text("스터디 정보를 불러오지 못했습니다."))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("이름: ${study!.name}", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text("설명: ${study!.description}"),
                  const SizedBox(height: 8),
                  Text("D-Day: ${study!.dueDate?.difference(DateTime.now()).inDays ?? '알 수 없음'}일 남음"),
                  const SizedBox(height: 8),
                  Text("색상: ${study!.personalColor}"),
                  const SizedBox(height: 16),
                  Text("스터디 멤버", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...study!.members.map((member) => Text("- ${member.userName}")).toList(),
                ],
              ),
            )
    );
  }
}