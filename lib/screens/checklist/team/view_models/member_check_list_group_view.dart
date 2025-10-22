import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/checklist_item/create/checklist_item_create_request.dart';
import 'package:study_group_front_end/dto/checklist_item/update/checklist_item_content_update_request.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/providers/checklist_item_provider.dart';
import 'package:study_group_front_end/providers/personal_checklist_provider.dart';
import 'package:study_group_front_end/screens/checklist/common/bottom/show_checklist_item_options_bottom_sheet.dart';
import 'package:study_group_front_end/screens/checklist/common/tile/parts/checklist_item_input_field.dart';
import 'package:study_group_front_end/screens/checklist/common/tile/parts/checklist_item_tile.dart';
import 'package:study_group_front_end/screens/checklist/team/tile/parts/member_header_chip.dart';
import 'package:study_group_front_end/screens/checklist/team/view_models/member_checklist_group_vm.dart';
import 'package:study_group_front_end/screens/checklist/team/view_models/member_checklist_item_vm.dart';
import 'package:study_group_front_end/util/color_converters.dart';

class MemberChecklistGroupView extends StatefulWidget {
  final StudyDetailResponse study;
  final DateTime selectedDate;
  final ScrollController? parentScrollController;

  const MemberChecklistGroupView({
    super.key,
    required this.study,
    required this.selectedDate,
    this.parentScrollController,
  });

  @override
  State<MemberChecklistGroupView> createState() => _MemberChecklistGroupViewState();
}

class _MemberChecklistGroupViewState extends State<MemberChecklistGroupView> {
  // Constants
  static const double _scrollThreshold = 50.0;
  static const double _scrollSpeed = 10.0;
  static const double _maxDraggableWidth = 400.0;
  static const double _emptyTargetHeight = 48.0;
  static const Duration _scrollDuration = Duration(milliseconds: 300);

  // State
  int? _editingMemberId;
  int? _editingItemId;
  late final Color _personalColor;

  // Controllers
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late VoidCallback _focusListener;

  @override
  void initState() {
    super.initState();
    _personalColor = hexToColor(widget.study.personalColor);

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
    final groups = provider.groups;

    if (provider.isLoading) {
      return _buildEmptyState();
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _quitEditing,
      child: ListView.separated(
        controller: _scrollController,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(22, 8, 16, 24),
        itemCount: groups.length,
        separatorBuilder: (_, __) => const SizedBox.shrink(),
        itemBuilder: (context, i) {
          final g = groups[i];
          final isEditing = (_editingMemberId == g.studyMemberId);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MemberHeaderChip(
                name: g.memberName,
                color: _personalColor,
                onAddPressed: () => _startEditing(g.studyMemberId),
              ),
              const SizedBox(height: 10),

              _buildChecklistItems(g, isEditing),

              if (isEditing) _buildNewItemInputField(g),
            ],
          );
        },
      ),
    );
  }

  // ==================== Widget Builders ====================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.checklist, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '화면이 로딩 중에 있습니다. 잠시만 기다려 주세요!',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItems(MemberChecklistGroupVM g, bool isEditing) {
    return Column(
      children: [
        if (g.items.isEmpty && !isEditing) _buildEmptyDragTarget(g),
        for (int i = 0; i < g.items.length; i++)
          _buildChecklistItemDragTarget(g, g.items[i], i),
      ],
    );
  }

  Widget _buildEmptyDragTarget(MemberChecklistGroupVM g) {
    final provider = context.watch<ChecklistItemProvider>();

    return DragTarget<MemberChecklistItemVM>(
      key: ValueKey('empty-target-${g.studyMemberId}'),
      onWillAcceptWithDetails: (dragged) {
        provider.setHoveredItem(dragged.data.id);
        provider.moveItem(
          item: dragged.data,
          fromMemberId: dragged.data.studyMemberId,
          fromIndex: provider.getIndexOf(dragged.data),
          toMemberId: g.studyMemberId,
          toIndex: 0,
        );
        return true;
      },
      onAcceptWithDetails: (dragged) {
        provider.clearHoveredItem(dragged.data.id);
        _reorderChecklists();
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        return Container(
          height: _emptyTargetHeight,
          decoration: BoxDecoration(
            border: Border.all(
              color: isHovered ? _personalColor : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isHovered ? _personalColor.withOpacity(0.1) : Colors.transparent,
          ),
        );
      },
    );
  }

  Widget _buildChecklistItemDragTarget(
      MemberChecklistGroupVM g,
      MemberChecklistItemVM item,
      int index,
      ) {
    final provider = context.watch<ChecklistItemProvider>();

    return DragTarget<MemberChecklistItemVM>(
      key: ValueKey('target-${item.id}'),
      onWillAcceptWithDetails: (dragged) {
        provider.setHoveredItem(item.id);
        provider.moveItem(
          item: dragged.data,
          fromMemberId: dragged.data.studyMemberId,
          fromIndex: provider.getIndexOf(dragged.data),
          toMemberId: g.studyMemberId,
          toIndex: index,
        );
        return true;
      },
      onMove: (dragged) => _handleAutoScroll(dragged.offset),
      onAcceptWithDetails: (dragged) {
        provider.clearHoveredItem(dragged.data.id);
        _reorderChecklists();
      },
      builder: (context, _, __) => _buildChecklistItemContent(item),
    );
  }

  Widget _buildChecklistItemContent(MemberChecklistItemVM item) {
    if (_editingItemId == item.id) {
      return _buildEditingField(item);
    }

    final provider = context.watch<ChecklistItemProvider>();
    final hoverStatus = provider.getHoverStatusOfItem(item.id);

    return switch (hoverStatus) {
      HoverStatus.hovering => _buildHoveredPlaceholder(item),
      HoverStatus.notHovering => _buildDraggableItem(item),
    };
  }

  Widget _buildHoveredPlaceholder(MemberChecklistItemVM item) {
    return Container(
      key: ValueKey('hovered-${item.id}'),
      height: _emptyTargetHeight,
      decoration: BoxDecoration(
        border: Border.all(color: _personalColor, width: 2.0),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
    );
  }

  Widget _buildDraggableItem(MemberChecklistItemVM item) {
    final provider = context.read<ChecklistItemProvider>();

    return LongPressDraggable<MemberChecklistItemVM>(
      key: ValueKey('draggable-${item.id}'),
      data: item,
      feedback: Material(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxDraggableWidth),
          child: _buildChecklistTile(item),
        ),
      ),
      onDragStarted: _quitEditing,
      onDraggableCanceled: (_, __) {
        provider.clearHoveredItem(item.id);
      },
      childWhenDragging: const SizedBox.shrink(),
      axis: Axis.vertical,
      child: _buildChecklistTile(item, showOptions: true),
    );
  }

  Widget _buildChecklistTile(MemberChecklistItemVM item, {bool showOptions = false}) {
    return ChecklistItemTile(
      itemId: item.id,
      studyId: widget.study.id,
      key: ValueKey('title-${item.id}'),
      context: ChecklistContext.TEAM,
      title: item.content,
      completed: item.completed,
      color: _personalColor,
      onMore: showOptions ? () => _showItemOptions(item) : () {},
    );
  }

  Widget _buildEditingField(MemberChecklistItemVM item) {
    return ChecklistItemInputField(
      key: ValueKey('editing-${item.id}'),
      color: _personalColor,
      completed: item.completed,
      controller: _controller,
      focusNode: _focusNode,
      onDone: () {},
      onSubmitted: (value) => _updateChecklistItemContent(item, value),
    );
  }

  Widget _buildNewItemInputField(MemberChecklistGroupVM g) {
    return ChecklistItemInputField(
      color: _personalColor,
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
      onSubmitted: (value) => _createChecklistItem(g, value),
    );
  }

  // ==================== Business Logic ====================

  Future<void> _updateChecklistItemContent(
      MemberChecklistItemVM item,
      String value,
      ) async {
    _finishEditing(item, updatedContent: value);

    try {
      final request = ChecklistItemContentUpdateRequest(content: value);
      final provider = context.read<ChecklistItemProvider>();
      await provider.updateChecklistItemContent(item.id, request);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("체크리스트 content 업데이트 실패: $e");
      }
      log("체크리스트 content 업데이트 실패: $e");
    }
  }

  Future<void> _createChecklistItem(
      MemberChecklistGroupVM group,
      String content,
      ) async {
    try {
      final request = ChecklistItemCreateRequest(
        content: content,
        assigneeId: group.studyMemberId,
        type: "STUDY",
        targetDate: widget.selectedDate,
        orderIndex: group.items.length,
      );

      final provider = context.read<ChecklistItemProvider>();
      await provider.createChecklistItem(request,widget.study.name);


      final personalProvider = context.read<PersonalChecklistProvider>();
      // await personalProvider.refresh();
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("생성 실패: $e");
      }
      log("생성 실패: $e");
    }
  }

  Future<void> _deleteChecklistItem(int itemId) async {
    try {
      final provider = context.read<ChecklistItemProvider>();
      await provider.softDeleteChecklistItem(itemId);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("체크리스트 삭제 실패: $e");
      }
      log("체크리스트 삭제 실패: $e");
    }
  }

  Future<void> _reorderChecklists() async {
    final provider = context.read<ChecklistItemProvider>();
    final requests = provider.buildReorderRequests();

    try {
      await provider.reorderChecklistItem(requests);
    } catch (e) {
      if (mounted){
        _showErrorSnackBar("체크리스트 reorder 실패: $e");
      }
    }
  }


  // ==================== UI Actions ====================

  void _showItemOptions(MemberChecklistItemVM item) {
    showChecklistItemOptionsBottomSheet(
      context: context,
      title: item.content,
      onEdit: () {
        Navigator.pop(context);
        _startUpdateEditing(item);
      },
      onDelete: () async {
        Navigator.pop(context);
        await _deleteChecklistItem(item.id);
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ==================== State Management ====================

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

  void _finishEditing(MemberChecklistItemVM item, {required String updatedContent}) {
    setState(() {
      item.content = updatedContent;
      _editingItemId = null;
      _controller.clear();
      _focusNode.unfocus();
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

  // ==================== Scroll Handling ====================

  void _scrollToInputField() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();

      // 부모 스크롤러가 있으면 사용
      if (widget.parentScrollController != null) {
        widget.parentScrollController!.animateTo(
          widget.parentScrollController!.position.maxScrollExtent,
          duration: _scrollDuration,
          curve: Curves.easeOut,
        );
      }
      // 없으면 Scrollable.ensureVisible 사용
      else if (_focusNode.context != null) {
        Scrollable.ensureVisible(
          _focusNode.context!,
          duration: _scrollDuration,
          curve: Curves.easeOut,
          alignment: 0.5,
        );
      }
    });
  }

  void _handleAutoScroll(Offset globalPosition) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final listHeight = renderBox.size.height;
    final localPosition = renderBox.globalToLocal(globalPosition);

    final currentOffset = _scrollController.offset;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final minScrollExtent = _scrollController.position.minScrollExtent;

    double? newOffset;

    // 상단으로 스크롤
    if (localPosition.dy < _scrollThreshold && currentOffset > minScrollExtent) {
      newOffset = (currentOffset - _scrollSpeed).clamp(minScrollExtent, maxScrollExtent);
    }
    // 하단으로 스크롤
    else if (localPosition.dy > listHeight - _scrollThreshold &&
        currentOffset < maxScrollExtent) {
      newOffset = (currentOffset + _scrollSpeed).clamp(minScrollExtent, maxScrollExtent);
    }

    if (newOffset != null) {
      _scrollController.jumpTo(newOffset);
    }
  }
}