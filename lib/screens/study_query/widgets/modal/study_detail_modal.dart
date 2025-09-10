import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/providers/me_provider.dart';
import 'package:study_group_front_end/providers/study_provider.dart';
import 'package:study_group_front_end/screens/checklist/widget/bottom_sheet/show_checklist_item_options_bottom_sheet.dart';
import 'package:study_group_front_end/screens/common_dialog/confirmationDialog.dart';
import 'package:study_group_front_end/screens/study_query/widgets/dialog/study_join_code_qr_dialog.dart';
import 'package:study_group_front_end/screens/study_query/widgets/modal/member_chip.dart';
import 'package:study_group_front_end/util/color_converters.dart';
import 'package:study_group_front_end/util/formatKoreanDate.dart';

Future<void> showStudyDetailModal({
  required BuildContext context,
  required StudyDetailResponse study,
  VoidCallback? onDeleted,
  }
) {
  final currentUserId = context.read<MeProvider>().currentMember?.id;
  bool isLeader = (study.leaderId == currentUserId);

  return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //title
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  study.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              //body
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabelAndChip(
                      context,
                      '팀장',
                      MemberChip(
                        name: study.leaderName,
                        color: hexToColor(study.personalColor),
                        onAddPressed: () {}
                      ),
                    ),
                    const SizedBox(height: 8),
                    Divider(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    _buildLabelAndChips(
                      context,
                      '팀원',
                      study.personalColor,
                      study.members.map((member) => member.userName).toList(),
                    ),
                    const SizedBox(height: 8),
                    Divider(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    if(isLeader) ... [
                      _buildInviteCodeRow(context, study.joinCode),
                      Divider(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ],
                    Text(
                      '프로젝트 마감일 : ${formatKoreanDate(study.dueDate)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                )
              ),
              const SizedBox(height: 12),

              //footer
              _buildModalFooter(
                //Todo: 상세정보 보기
                isLeader: isLeader,
                onDetailPressed: () {
                  context.push('/studies/${study.id}');

                  Navigator.of(context).pop();
                },
                onDeletePressed: () {
                  _confirmAndDeleteStudy(context, study.id, study.personalColor);
                },
                onLeavePressed: () {
                  Navigator.of(context).pop();
                  //Todo: 스터디 탈퇴 로직
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      }
  );
}

Widget _buildLabelAndChip(BuildContext context, String label, Widget chip) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(width: 10),
      chip,
    ],
  );
}

Widget _buildLabelAndChips(BuildContext context, String label, String color, List<String> names) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(width: 10),

      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: names.map((name) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: MemberChip(
                name: name,
                color: hexToColor(color),
                onAddPressed: () {},
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}

Widget _buildInviteCodeRow(BuildContext context, String inviteCode) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            '참여코드: $inviteCode',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        SizedBox(width: 30),
        IconButton(
          onPressed: (){
            showDialog(
                context: context,
                builder: (_) => StudyJoinCodeToQrDialog(joinCode: inviteCode)
            );
          },
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.qr_code, size: 20,)
        ),
      ],
  );
}

Widget _buildModalFooter({
  required bool isLeader,
  required VoidCallback onDetailPressed,
  required VoidCallback onDeletePressed,
  required VoidCallback onLeavePressed,
}) {

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // 상세정보 버튼
      Expanded(
        child:
          ActionButton(icon: Icons.info_outline, label: '상세정보', onTap: onDetailPressed),
      ),
      const SizedBox(width: 15),
      // 리더냐 아니냐에 따라 오른쪽 버튼 변경
      Expanded(
        child: isLeader
            ? ActionButton(icon: Icons.delete_outline, label: '삭제', onTap: onDeletePressed, color: Colors.redAccent)
            : ActionButton(icon: Icons.exit_to_app, label: '탈퇴', onTap: onLeavePressed, color: Colors.redAccent)
      ),
    ],
  );
}


Future<void> _confirmAndDeleteStudy(BuildContext context, int studyId, String color) async {
  final confirmed = await showConfirmationDialog(
    context: context,
    title: "정말 삭제 하시겠어요?",
    description: "삭제한 팀 프로젝트는 모든 내용이 지워지고\n 그 후로는 복구가 어렵습니다.",
    confirmColor: hexToColor(color),
  );

  log("confirm: $confirmed");

  if (confirmed != true) return;

  try {
    await context.read<StudyProvider>().deleteStudy(studyId);
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('스터디가 삭제되었습니다.')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: $e')),
      );
    }
  }
}


