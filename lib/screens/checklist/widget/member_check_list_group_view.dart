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
import 'package:study_group_front_end/screens/checklist/widget/checklists_tile/view_models/member_checklist_item_vm.dart';
import 'package:study_group_front_end/util/color_converters.dart';

class MemberChecklistGroupView extends StatefulWidget {
  final StudyDetailResponse study;
  final DateTime selectedDate;
  final void Function()? onChecklistCreated;

  const MemberChecklistGroupView({
    super.key,
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
  late ChecklistItemProvider _checklistItemProvider;

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
    final provider = context.watch<ChecklistItemProvider>();
    // log("들어왔는지 판단하기: ${provider.groups[0].items.length}");
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _controller.text = "";
        FocusScope.of(context).unfocus();
        _editingItemId = null;
        _editingMemberId = null;
      },
      // onLongPress: () {
      //   _controller.text = "";
      //   FocusScope.of(context).unfocus();
      //   _editingItemId = null;
      //   _editingMemberId = null;
      // },
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(22, 8, 16, 24),
        itemCount: provider.groups.length,
        separatorBuilder: (_, __) => const SizedBox.shrink(),
        itemBuilder: (context, i) {
          final g = provider.groups[i];
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

              Column(
                children: [
                  for (int i=0; i < g.items.length; i++) ...[
                    DragTarget<MemberChecklistItemVM>(
                      key: ValueKey('target-${g.items[i].id}'),
                      onWillAcceptWithDetails: (dragged) {
                        // log("${dragged.data.content}의 현재 위치: ${g.items[i].content}");
                        provider.setHoveredItem(g.items[i].id);
                        provider.moveItem(
                            item: dragged.data,
                            fromMemberId: dragged.data.studyMemberId,
                            fromIndex: provider.getIndexOf(dragged.data),
                            toMemberId: g.studyMemberId,
                            toIndex: i
                        );
                        return true;
                      },
                      onLeave: (dragged) {
                        log("인덱스 : ${dragged?.content}");
                        // provider.clearHoveredItemAndResetTimer(dragged!.id);
                        // provider.clearHoveredItemAndStartTimer(dragged!.id);
                      },
                      onAcceptWithDetails: (dragged) {
                        provider.clearHoveredItemAndResetTimer(dragged.data.id);
                        // provider.moveItem(
                        //     item: dragged.data,
                        //     fromMemberId: dragged.data.studyMemberId,
                        //     fromIndex: provider.getIndexOf(dragged.data),
                        //     toMemberId: g.studyMemberId,
                        //     toIndex: i
                        // );
                      },
                      builder: (context, candidateDate, rejectedData) {
                        final it = g.items[i];
                        // final isHovered = provider.isHoveringItem(it.id);
                        final hoverStatus = provider.getHoverStatusOfItem(it.id);
                        // final isBeingDragged = provider.isDraggingItem(it.id);
                        if (_editingItemId == it.id) {
                          return ChecklistItemInputField(
                              key: ValueKey('title-${it.id}'),
                              color: hexToColor(widget.study.personalColor),
                              controller: _controller,
                              focusNode: _focusNode,
                              onDone: () {
                                setState(() {
                                  _editingItemId = null;
                                  _controller.clear();
                                  _focusNode.unfocus();
                                });
                              },
                              onSubmitted: (value) async {
                                setState(() {
                                  it.content = value;
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
                          );
                        }
                        else {
                          return switch (hoverStatus) {
                            HoverStatus.hovering =>
                              Container(
                                key: ValueKey('hovered-${it.id}'),
                                height: 48,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: hexToColor(
                                        widget.study.personalColor),
                                    // 원하는 테두리 색상
                                    width: 2.0, // 테두리 두께
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  // 선택: 둥근 테두리
                                  color: Colors.white, // 선택: 배경색
                                ),
                              ),

                            HoverStatus.notHovering =>
                              LongPressDraggable<MemberChecklistItemVM>(
                                key: ValueKey('draggable-${it.id}'),
                                data: it,
                                feedback: Material(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        maxWidth: 400),
                                    child: ChecklistItemTile(
                                        title: it.content,
                                        completed: it.completed,
                                        color: hexToColor(
                                            widget.study.personalColor),
                                        onMore: () {}
                                    ),
                                  ),
                                ),
                                onDragStarted: () {
                                  _controller.text = "";
                                  FocusScope.of(context).unfocus();
                                  _editingItemId = null;
                                  _editingMemberId = null;
                                },
                                onDragCompleted: () {
                                  log("onDragCompleted");
                                },
                                onDraggableCanceled: (_, _) {
                                  log("onDraggableCanceled");
                                  provider.clearHoveredItemAndResetTimer(
                                      it.id);
                                },
                                childWhenDragging:
                                const SizedBox.shrink(),
                                axis: Axis.vertical,
                                child: ChecklistItemTile(
                                    key: ValueKey('title-${it.id}'),
                                    title: it.content,
                                    completed: it.completed,
                                    color: hexToColor(
                                        widget.study.personalColor),
                                    onMore: () {
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
                          };
                        }
                      }
                    ),
                  ],
                ],
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
