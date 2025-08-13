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
  final void Function()? onChecklistCreated;

  const MemberChecklistGroupView({
    super.key,
    required this.groups,
    required this.study,
    required this.selectedDate,
    this.onChecklistCreated,
  });

  @override
  State<MemberChecklistGroupView> createState() => _MemberChecklistGroupViewState();
}

class _MemberChecklistGroupViewState extends State<MemberChecklistGroupView> {
  int? editingMemberId;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late VoidCallback _focusListener;

  @override
  void initState() {
    super.initState();

    _focusListener = () {
      if (!_focusNode.hasFocus) {
        setState(() {
          editingMemberId = null;
          _controller.clear();
        });
      }
    };

    _focusNode.addListener(_focusListener);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_focusListener);
    _focusNode.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ListView.separated(
        controller: _scrollController,
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
                    _scrollToInputField();
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
                        _controller.clear();
                        _focusNode
                          ..unfocus()
                          ..requestFocus();
                        _scrollToInputField();
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
                        widget.onChecklistCreated?.call();
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
      ),
    );
  }

  void _scrollToInputField() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}
