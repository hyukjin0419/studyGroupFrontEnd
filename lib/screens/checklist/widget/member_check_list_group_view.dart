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

  const MemberChecklistGroupView({
    super.key,
    required this.study,
    required this.selectedDate,
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
    final provider = context.watch<ChecklistItemProvider>();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _quitEditing,
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
                onAddPressed: () => _startEditing(g.studyMemberId),
              ),
              const SizedBox(height: 10),

              Column(
                children: [
                  if (g.items.isEmpty && !isEditing)
                    DragTarget<MemberChecklistItemVM>(
                      key: ValueKey('empty-target-${g.studyMemberId}'),
                      onWillAcceptWithDetails: (dragged) {
                        provider.setHoveredItem(dragged.data.id);
                        provider.moveItem(
                          item: dragged.data,
                          fromMemberId: dragged.data.studyMemberId,
                          fromIndex: provider.getIndexOf(dragged.data),
                          toMemberId: g.studyMemberId,
                          toIndex: 0, // 항상 0
                        );
                        return true;
                      },
                      onAcceptWithDetails: (dragged) {
                        provider.clearHoveredItem(dragged.data.id);
                        // provider.reorderChecklistItem();
                      },
                      builder: (context, candidateData, rejectedData) {
                        final isHovered = candidateData.isNotEmpty;
                        return Container(
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isHovered
                                  ? hexToColor(widget.study.personalColor)
                                  : Colors.transparent,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: isHovered
                                ? hexToColor(widget.study.personalColor).withOpacity(0.1)
                                : Colors.transparent,
                          ),
                        );
                      },
                    ),
                  for (int i=0; i < g.items.length; i++) ...[
                    DragTarget<MemberChecklistItemVM>(
                      key: ValueKey('target-${g.items[i].id}'),
                      onWillAcceptWithDetails: (dragged) {
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
                      onMove: (dragged) {
                        _handleAutoScroll(dragged.offset);
                      },
                      onAcceptWithDetails: (dragged) {
                        provider.clearHoveredItem(dragged.data.id);
                        // provider.reorderChecklistItem();
                        // provider.updateGroups();
                      },
                      builder: (context, _, __) {
                        final it = g.items[i];
                        final hoverStatus = provider.getHoverStatusOfItem(it.id);
                        if (_editingItemId == it.id) {
                          return ChecklistItemInputField(
                              key: ValueKey('title-${it.id}'),
                              color: hexToColor(widget.study.personalColor),
                              completed: it.completed,
                              controller: _controller,
                              focusNode: _focusNode,
                              onDone: () {},
                              onSubmitted: (value) async {
                                //it이 전역이 아닌데도 사용할 수 있음은 Dart의 Closure 기능 때문
                                _finishEditing(it, updatedContent: value);
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
                                      itemId: it.id,
                                      title: it.content,
                                      completed: it.completed,
                                      color: hexToColor(
                                          widget.study.personalColor),
                                      onMore: () {}
                                    ),
                                  ),
                                ),
                                onDragStarted: _quitEditing,
                                onDraggableCanceled: (_, _) {
                                  provider.clearHoveredItem(it.id);
                                },
                                childWhenDragging:
                                const SizedBox.shrink(),
                                axis: Axis.vertical,
                                child: ChecklistItemTile(
                                    itemId: it.id,
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
                                            Navigator.pop(context);
                                            _startUpdateEditing(it);
                                          },
                                          onDelete: () async {
                                            Navigator.pop(context);
                                            try {
                                              final provider = context.read<ChecklistItemProvider>();
                                              await provider.softDeleteChecklistItem(it.id);
                                            } catch(e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text("체크리스트 삭제 실패: $e")),
                                              );
                                            }
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
                      try {
                        final request = ChecklistItemCreateRequest(
                            content: value,
                            assigneeId: g.studyMemberId,
                            type: "STUDY",
                            targetDate: widget.selectedDate,
                            orderIndex: g.items.length,
                        );

                        final provider = context.read<ChecklistItemProvider>();
                        await provider.createChecklistItem(request);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("생성 실패: $e")),
                        );
                        log("생성 실패: $e");
                      }
                    }
                )
            ],
          );
        }
      ),
    );
  }


//------------------------------화면 로직------------------------------//
  void _startEditing(int studyMemberId) {
    setState(() {
      _editingItemId = null;
      _editingMemberId = studyMemberId;
      _controller.clear();
      _scrollToInputField();
    });
  }

  void _quitEditing() {
    setState(() {
      _editingItemId = null;
      _editingMemberId = null;
      _controller.clear();
      _focusNode.unfocus();
    });
  }

  void _finishEditing(it, {required String updatedContent}) {
    setState(() {
      it.content = updatedContent;
      _editingItemId = null;
      _controller.clear();
      _focusNode.unfocus();
    });
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

  void _startUpdateEditing(MemberChecklistItemVM item) {
    setState(() {
      _editingMemberId = null;
      _controller.text = item.content;
      _editingItemId = item.id;
      _focusNode.requestFocus();
    });
  }

  void _handleAutoScroll(Offset globalPosition) {
    const scrollThreshold = 50.0; // 스크롤이 시작될 경계
    const scrollSpeed = 10.0; // 스크롤 속도

    final renderBox = context.findRenderObject() as RenderBox;
    final listHeight = renderBox.size.height;
    final localPosition = renderBox.globalToLocal(globalPosition);

    final currentOffset = _scrollController.offset;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final minScrollExtent = _scrollController.position.minScrollExtent;

    // 상단으로 스크롤
    if (localPosition.dy < scrollThreshold && currentOffset > minScrollExtent) {
      _scrollController.jumpTo((currentOffset - scrollSpeed).clamp(minScrollExtent, maxScrollExtent));
    }
    // 하단으로 스크롤
    else if (localPosition.dy > listHeight - scrollThreshold && currentOffset < maxScrollExtent) {
      _scrollController.jumpTo((currentOffset + scrollSpeed).clamp(minScrollExtent, maxScrollExtent));
    }
  }
}
