import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/providers/me_provider.dart';
import 'package:study_group_front_end/providers/study_provider.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/dto/study/update/study_update_request.dart';
import 'package:study_group_front_end/screens/study/widgets/dialog/study_join_code_qr_dialog.dart';
import 'package:study_group_front_end/screens/study/widgets/dialog/update_study_dialog.dart';
import 'package:study_group_front_end/util/color_converters.dart';
import 'package:study_group_front_end/widgets/common_bottom_sheet.dart';

class StudyCard extends StatelessWidget {
  final StudyDetailResponse study;

  const StudyCard({super.key, required this.study});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:(){
        context.push(
          '/studies/${study.id}/checklists',
          extra: study,
        );
      },
      child: Card(
      color: hexToColor(study.personalColor),
        child: Stack(
          children: [
            Positioned(
              top: 2,
              right: -8,
              child: IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () {
                  _showCustomizedModal(context);
                },
              )
            ),
            // const SizedBox(height: 16),
            // const Spacer(),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(study.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 6,
                      child:
                      LinearProgressIndicator(
                        value: study.progress,
                        backgroundColor: Colors.white38,
                        color: Colors.white
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${(study.progress * 100).round()}%', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  const Spacer(),
                  Text(study.dueDate.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  Text(study.status, style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomizedModal(BuildContext context) {
    final currentUserId = context.read<MeProvider>().currentMember?.id;
    final isLeader = currentUserId == study.leaderId;
    
    showCommonBottomSheet(context,
      [
        BottomSheetItem(
            icon: Icons.info_outline,
            text: '정보 보기',
            onTap: () {
              log('정보보기 클릭',name: 'StudyCard');
              context.push('/studies/${study.id}');
            }
        ),
        if(isLeader)
          BottomSheetItem(
              icon: Icons.qr_code_scanner,
              text: "스터디 코드 제공하기",
              onTap: (){
                log('스터디 코드 제공하기 클릭',name: 'StudyCard');
                showDialog(
                    context: context,
                    builder: (_) => StudyJoinCodeToQrDialog(joinCode: study.joinCode)
                );
              }
          ),
        if(isLeader)
          BottomSheetItem(
              icon: Icons.person_add,
              text: "스터디 멤버 초대하기",
              onTap: (){
                log('스터디 멤버 초대하기 클릭',name: 'StudyCard');
                context.push('/studies/invitation/${study.id}');
              }
          ),
        if(isLeader)
          BottomSheetItem(
              icon: Icons.edit,
              text: '수정',
              onTap: () {
                log('수정 클릭',name: 'StudyCard');
                showDialog(
                  context: context,
                  builder: (_) => UpdateStudyDialog(
                    // studyId: study.id,
                    initialData: StudyUpdateRequest(
                      studyId: study.id,
                      name: study.name,
                      description: study.description,
                      personalColor: study.personalColor,
                      dueDate: study.dueDate,
                    ),
                  ),
                );
              }
          ),
        if(isLeader)
        BottomSheetItem(
            icon: Icons.delete,
            text: '삭제',
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: () async {
              log('삭제 클릭',name: 'StudyCard');
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('삭제 확인'),
                  content: const Text('정말 이 스터디를 삭제하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('취소'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('삭제'),
                    ),
                  ],
                ),
              );

              if (confirmed != true) return;

              try {
                await context.read<StudyProvider>().deleteStudy(study.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('스터디가 삭제되었습니다.')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('삭제 실패: $e')),
                );
              }
            }
        ),
      ]
    );
  }
}
