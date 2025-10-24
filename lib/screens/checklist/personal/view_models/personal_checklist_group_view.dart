import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/providers/checklist_item_provider.dart';
import 'package:study_group_front_end/providers/personal_checklist_provider.dart';
import 'package:study_group_front_end/screens/checklist/common/bottom/show_checklist_item_options_bottom_sheet.dart';
import 'package:study_group_front_end/screens/checklist/common/tile/parts/checklist_item_input_field.dart';
import 'package:study_group_front_end/screens/checklist/common/tile/parts/checklist_item_tile.dart';
import 'package:study_group_front_end/screens/checklist/personal/tile/parts/study_header_chip.dart';
import 'package:study_group_front_end/screens/checklist/personal/view_models/personal_checklist_group_vm.dart';


class PersonalChecklistGroupView extends StatefulWidget {
  final DateTime selectedDate;
  final Color primaryColor;
  final ScrollController? parentScrollController;

  const PersonalChecklistGroupView({
    super.key,
    required this.selectedDate,
    required this.primaryColor,
    this.parentScrollController,
  });

  @override
  State<PersonalChecklistGroupView> createState() => _PersonalChecklistGroupViewState();
}

class _PersonalChecklistGroupViewState extends State<PersonalChecklistGroupView> {
  static const double _scrollThreshold = 50.0;
  static const double _scrollSpeed = 10.0;
  static const double _maxDraggableWidth = 400.0;
  static const double _emptyTargetHeight = 48.0;
  static const Duration _scrollDuration = Duration(milliseconds: 300);

  int? _editingStudyId;
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
          _editingStudyId = null;
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
    final provider = context.watch<PersonalChecklistProvider>();
    final groups = provider.groups;
    //MVP 이후 TODO 색상 어떻게 할건지 생각해봐야 함. -> 나중에 title 옆에 색상 변경 버튼 추가? or study 별로 study 색상 불러올건지?
    final color = Colors.teal;

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
          final group = groups[i];
          final isEditing = (_editingStudyId == group.studyId);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StudyHeaderChip(
                name: group.studyName,
                color: color,
                onAddPressed: () => _startEditing(group.studyId),
              ),
              const SizedBox(height: 10),

              _buildChecklistItems(group, isEditing),

              if (isEditing) _buildNewItemInputField(group.studyId),
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

  Widget _buildChecklistItems(PersonalCheckListGroupVM g, bool isEditing) {
    return Column(
      children: [
        if(g.items.isEmpty && !isEditing) _buildEmptyDragTarget(g),
        for(int i = 0;i < g.items.length; i++)
          _buildChecklistItemDragTarget(g, g.items[i], i),
      ],
    );
  }


  Widget _buildEmptyDragTarget(PersonalCheckListGroupVM g){
    final provider = context.watch<PersonalChecklistProvider>();

    return DragTarget<ChecklistItemDetailResponse>(
      key: ValueKey('personal-empty-target-${g.studyId}'),
      onWillAcceptWithDetails: (dragged) {
        provider.setHoveredItem(dragged.data.id);
        //TODO MVP 완성 이후 안정장치 추가해주어야 함
        provider.moveItem(
          item: dragged.data,
          fromStudyId: dragged.data.studyId,
          fromIndex: provider.getIndexOf(dragged.data),
          toStudyId: g.studyId,
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
            border:  Border.all(
              color: isHovered ? widget.primaryColor : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isHovered ? widget.primaryColor.withOpacity(0.1) : Colors.transparent,
          ),
        );
      },
    );
  }

  Widget _buildChecklistItemDragTarget(
    PersonalCheckListGroupVM g,
    ChecklistItemDetailResponse item,
    int index,
  ) {
    final provider = context.watch<PersonalChecklistProvider>();


    return DragTarget<ChecklistItemDetailResponse>(
      key: ValueKey('personal-target-${item.id}'),
      onWillAcceptWithDetails: (dragged) {
        provider.setHoveredItem(item.id);
        provider.moveItem(
          item: dragged.data,
          fromStudyId: dragged.data.studyId,
          fromIndex: provider.getIndexOf(dragged.data),
          toStudyId: g.studyId,
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

  Widget _buildChecklistItemContent(ChecklistItemDetailResponse item) {
    if (_editingItemId == item.id) {
      return _buildEditingField(item);
    }

    final provider = context.watch<PersonalChecklistProvider>();
    final hoverStatus = provider.getHoverStatusOfItem(item.id);

    return switch (hoverStatus) {
      HoverStatus.hovering => _buildHoveredPlaceholder(item),
      HoverStatus.notHovering => _buildDraggableItem(item),
    };
  }

  Widget _buildHoveredPlaceholder(ChecklistItemDetailResponse item) {
    return Container(
      key: ValueKey('personal-hovered-${item.id}'),
      height: _emptyTargetHeight,
      decoration: BoxDecoration(
        border: Border.all(color: widget.primaryColor, width: 2.0),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
    );
  }

  Widget _buildDraggableItem(ChecklistItemDetailResponse item) {
    final provider = context.read<PersonalChecklistProvider>();

    return LongPressDraggable<ChecklistItemDetailResponse>(
      key: ValueKey('personal-draggable-${item.id}'),
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

  Widget _buildChecklistTile(ChecklistItemDetailResponse item, {bool showOptions = false}) {
    return ChecklistItemTile(
      itemId: item.id,
      studyId: item.studyId,
      key: ValueKey('personal-title-${item.id}'),
      context: ChecklistContext.TEAM,
      title: item.content,
      completed: item.completed,
      color: widget.primaryColor,
      onMore: showOptions ? () => _showItemOptions(item) : () {},
    );
  }

  Widget _buildEditingField(item) {
    return ChecklistItemInputField(
      key: ValueKey('personal-editing-${item.id}'),
      color: widget.primaryColor,
      completed: item.completed,
      controller: _controller,
      focusNode: _focusNode,
      onDone: () {},
      onSubmitted: (value) => _updateChecklistItemContent(item, value),
    );
  }

  Widget _buildNewItemInputField(int studyId) {
    return ChecklistItemInputField(
      color: widget.primaryColor,
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
      onSubmitted: (value) => _createChecklistItem(studyId, value),
    );
  }

  // ==================== Business Logic ====================
  Future<void> _createChecklistItem(int studyId, String content) async {
    try {
      final provider = context.read<PersonalChecklistProvider>();
      await provider.createPersonalChecklist(studyId, content);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("생성 실패: $e");
      }
      log("체크리스트 생성 실패?: $e");
    }
  }

  Future<void> _updateChecklistItemContent(ChecklistItemDetailResponse item, String value) async {
    _finishEditing(item, updatedContent: value);

    try {
      final ChecklistItemDetailResponse newItem = item.copyWith(content: value);
      final provider = context.read<PersonalChecklistProvider>();
      await provider.updateChecklistItemContent(newItem);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("수정 실패: $e");
      }
      log("체크리스트 수정 실패: $e");
    }
  }

  Future<void> _deleteChecklistItem(int itemId) async {
    try {
      //TODO provider 활성화
      final provider = context.read<PersonalChecklistProvider>();
      // await provider.deleteItem(itemId);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("삭제 실패: $e");
      }
      log("체크리스트 삭제 실패: $e");
    }
  }

  Future<void> _reorderChecklists() async {
    final provider = context.read<PersonalChecklistProvider>();
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

  void _showItemOptions(ChecklistItemDetailResponse item) {
    final rootContext = Navigator.of(context, rootNavigator: true).context;

    showChecklistItemOptionsBottomSheet(
      context: context,
      title: item.content,
      onEdit: () {
        Navigator.of(rootContext).pop();
        _startUpdateEditing(item);
      },
      onDelete: () async {
        Navigator.of(rootContext).pop();
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

  void _startEditing(int studyId) {
    setState(() {
      _editingItemId = null;
      _editingStudyId = studyId;
      _controller.clear();
      _focusNode.requestFocus();
    });
  }

  void _quitEditing() {
    setState(() {
      _editingItemId = null;
      _editingStudyId = null;
      _controller.clear();
      _focusNode.unfocus();
    });
  }

  void _finishEditing(ChecklistItemDetailResponse item, {required String updatedContent}) {
    setState(() {
      item = item.copyWith(content: updatedContent);
      _editingItemId = null;
      _controller.clear();
      _focusNode.unfocus();
    });
  }

  void _startUpdateEditing(item) {
    setState(() {
      _editingStudyId = null;
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