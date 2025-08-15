import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/checklist_item/create/checklist_item_create_request.dart';
import 'package:study_group_front_end/dto/checklist_item/update/checklist_item_content_update_request.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/providers/checklist_item_provider.dart';
import 'package:study_group_front_end/screens/checklist/widget/bottom_sheet/show_checklist_item_options_bottom_sheet.dart';
import 'package:study_group_front_end/screens/checklist/widget/checklists_tile/checklist_item_input_field.dart';
import 'package:study_group_front_end/screens/checklist/widget/checklists_tile/checklist_item_tile.dart';
import 'package:study_group_front_end/screens/checklist/widget/checklists_tile/member_header_chip.dart';
import 'package:study_group_front_end/screens/checklist/widget/checklists_tile/view_models/member_checklist_group_vm.dart';
import 'package:study_group_front_end/screens/checklist/widget/checklists_tile/view_models/member_checklist_item_vm.dart';
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
  int? _editingMemberId;
  int? _editingItemId;
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
          _controller.clear();
          _editingMemberId = null;
          _editingItemId = null;
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
        _controller.text = "";
        FocusScope.of(context).unfocus();
        _editingItemId = null;
        _editingMemberId = null;
      },
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(22, 8, 16, 24),
        itemCount: widget.groups.length,
        separatorBuilder: (_, __) => const SizedBox.shrink(),
        itemBuilder: (context, i) {
          final g = widget.groups[i];
          final isEditing = (_editingMemberId == g.studyMemberId);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MemberHeaderChip(
                name: g.memberName,
                color: hexToColor(widget.study.personalColor),
                onAddPressed: (){
                  log("working");
                  setState(() {
                    _editingItemId = null;
                    _editingMemberId = g.studyMemberId;
                    _controller.text = "";
                    _scrollToInputField();
                  });
                },
              ),
              const SizedBox(height: 10),
              ...g.items.map((it) =>
              _editingItemId == it.id ?
                ChecklistItemInputField(
                  key: ValueKey('title-${it.id}'),
                  color: hexToColor(widget.study.personalColor),
                  controller: _controller,
                  focusNode: _focusNode,
                  onDone: () {
                    setState(() {
                      log("$g");
                      log("${widget.groups}");
                      _editingItemId = null;
                      _controller.clear();
                      _focusNode.unfocus();
                    });
                  },
                  onSubmitted: (value) async {
                    setState(() {
                      it.content = value;
                      log("content value: ${it.content}");
                      _editingItemId = null;
                      _controller.clear();
                      _focusNode.unfocus();
                    });
                    //TODO checklist item update api 호출
                    try {
                      final request = ChecklistItemContentUpdateRequest(
                        content: value,
                      );

                      final provider = context.read<ChecklistItemProvider>();
                      await provider.updateChecklistItemContent(it.id, request);
                      // widget.onChecklistCreated?.call();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("체크리스트 content 업데이트 실패: $e")),
                      );
                      log("체크리스트 content 업데이트 실패: $e");
                    }
                  }
                )
                :
                ChecklistItemTile(
                  key: ValueKey('title-${it.id}'),
                  title: it.content,
                  completed: it.completed,
                  color: hexToColor(widget.study.personalColor),
                  onMore:() {
                    //TODO 삭제 및
                    showChecklistItemOptionsBottomSheet(
                        context: context,
                        title: it.content,
                        onEdit: () {
                          log("edit pressed");
                          Navigator.pop(context);
                          _startEditing(it);
                        },
                        onDelete: () {
                          Navigator.pop(context);
                          log("delete pressed");
                        }
                    );
                  }
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

  void _startEditing(MemberChecklistItemVM item) {
    setState(() {
      _editingMemberId = null;
      _controller.text = item.content;
      _editingItemId = item.id;
      _focusNode.requestFocus();
    });
  }
}
