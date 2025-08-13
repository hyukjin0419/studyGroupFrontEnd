import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/checklist_item/create/checklist_item_create_request.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/providers/checklist_item_provider.dart';
import 'package:study_group_front_end/screens/checklist/widget/checklists_tile/checklist_item_input_field.dart';
import 'package:study_group_front_end/screens/checklist/widget/checklists_tile/checklist_item_tile.dart';
import 'package:study_group_front_end/screens/checklist/widget/checklists_tile/member_header_chip.dart';
import 'package:study_group_front_end/screens/checklist/widget/checklists_tile/view_models/member_checklist_group_vm.dart';
import 'package:study_group_front_end/util/color_converters.dart';

class MemberChecklistGroupView extends StatefulWidget {
  final List<MemberChecklistGroupVM> groups;
  final StudyDetailResponse study;
  final DateTime selectedDate;

  const MemberChecklistGroupView({
    super.key,
    required this.groups,
    required this.study,
    required this.selectedDate,
  });

  @override
  State<MemberChecklistGroupView> createState() => _MemberChecklistGroupViewState();
}

class _MemberChecklistGroupViewState extends State<MemberChecklistGroupView> {
  int? editingMemberId;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(22, 8, 16, 24),
      itemCount: widget.groups.length,
      separatorBuilder: (_, __) => const SizedBox.shrink(),
      itemBuilder: (context, i) {
        final g = widget.groups[i];
        final isEditing = editingMemberId == g.studyMemberId;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MemberHeaderChip(
              name: g.memberName,
              color: hexToColor(widget.study.personalColor),
              onAddPressed: (){
                log("working");
                setState(() {
                  editingMemberId = g.studyMemberId;
                  _controller.text = "";
                  Future.delayed(Duration.zero, () => _focusNode.requestFocus());
                });
              },
            ),
            const SizedBox(height: 10),
            ...g.items.map((it) =>
              ChecklistItemTile(
                title: it.content,
                completed: it.completed,
                color: hexToColor(widget.study.personalColor),
                onMore:() {}
              ),
            ),

            if(isEditing)
              ChecklistItemInputField(
                  color: hexToColor(widget.study.personalColor),
                  controller: _controller,
                  focusNode: _focusNode,
                  onDone: () {
                    setState(() {
                      editingMemberId = null;
                      _controller.clear();
                      _focusNode.unfocus();
                    });
                  },
                  onSubmitted: (value) async {
                    log("생성할 항목: $value, 대상 멤버 ID: ${g.studyMemberId}");
                    log("orderIndex: ${g.items.length}");
                    //TODO: API 호출
                    try {
                      final request = ChecklistItemCreateRequest(
                          content: value,
                          assigneeId: g.studyMemberId,
                          type: "STUDY",
                          targetDate: widget.selectedDate,
                          orderIndex: g.items.length,
                      );

                      final provider = context.read<ChecklistItemProvider>();
                      await provider.createChecklistItem(request, widget.study.id);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("체크리스트 아이템 생성 실패: $e")),
                      );
                      log("체크리스트 아이템 생성 실패: $e");
                    }
                  }
              )
          ],
        );
      }
    );
  }
}