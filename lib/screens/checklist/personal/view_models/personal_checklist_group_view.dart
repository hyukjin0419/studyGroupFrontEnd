// screens/checklist/personal/widgets/personal_checklist_list_view.dart

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/checklist_item/create/checklist_item_create_request.dart';
import 'package:study_group_front_end/dto/checklist_item/update/checklist_item_content_update_request.dart';
import 'package:study_group_front_end/providers/checklist_item_provider.dart';
import 'package:study_group_front_end/providers/personal_checklist_provider.dart';
import 'package:study_group_front_end/screens/checklist/common/bottom/show_checklist_item_options_bottom_sheet.dart';
import 'package:study_group_front_end/screens/checklist/common/tile/parts/checklist_item_input_field.dart';
import 'package:study_group_front_end/screens/checklist/common/tile/parts/checklist_item_tile.dart';
import 'package:study_group_front_end/screens/checklist/personal/tile/parts/study_header_chip.dart';


class PersonalChecklistGroupView extends StatefulWidget {
  final DateTime selectedDate;
  final Color primaryColor;

  const PersonalChecklistGroupView({
    super.key,
    required this.selectedDate,
    required this.primaryColor,
  });

  @override
  State<PersonalChecklistGroupView> createState() => _PersonalChecklistGroupViewState();
}

class _PersonalChecklistGroupViewState extends State<PersonalChecklistGroupView> {
  // State - 스터디별 편집 상태 관리
  int? _editingStudyId;
  int? _editingItemId;

  // Controllers
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  //Providers
  late PersonalChecklistProvider personalProvider;
  late ChecklistItemProvider teamProvider;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _controller.clear();
          _editingStudyId = null;
          _editingItemId = null;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    personalProvider = context.read<PersonalChecklistProvider>();
    teamProvider = context.read<ChecklistItemProvider>();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PersonalChecklistProvider>();
    final groups = provider.groupByStudy;
    //색상 어떻게 할건지 생각해봐야 함.
    final color = Colors.teal;

    if (groups.isEmpty) {
      return _buildEmptyState();
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _quitEditing,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(22, 8, 16, 24),
        itemCount: groups.length,
        separatorBuilder: (_, __) => const SizedBox.shrink(),
        itemBuilder: (context, index) {
          final entry = groups.entries.elementAt(index);
          final group = entry.value;
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

  Widget _buildChecklistItems(group, bool isEditing) {
    return Column(
      children: [
        ...[...group.incomplete, ...group.completed].map((item) =>
            _buildChecklistItemWidget(item, group.studyId)
        ),
      ],
    );
  }

  Widget _buildChecklistItemWidget(item, int studyId) {
    // 편집 중인 아이템이면 편집 필드 표시
    if (_editingItemId == item.id) {
      return _buildEditingField(item);
    }

    // 일반 체크리스트 타일
    return ChecklistItemTile(
      itemId: item.id,
      studyId: studyId,
      key: ValueKey('title-${item.id}'),
      context: ChecklistContext.PERSONAL,
      title: item.content,
      completed: item.completed,
      color: widget.primaryColor,
      onMore: () => _showItemOptions(item, studyId),
    );
  }

  Widget _buildEditingField(item) {
    return ChecklistItemInputField(
      key: ValueKey('editing-${item.id}'),
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
          _focusNode.requestFocus();
        });
      },
      onSubmitted: (value) => _createChecklistItem(studyId, value),
    );
  }

  // ==================== Business Logic ====================
  Future<void> _createChecklistItem(int studyId, String content) async {
    try {
      final provider = context.read<PersonalChecklistProvider>();
      await provider.createPersonalChecklist(
        content: content,
        targetDate: widget.selectedDate,
        studyId: studyId,

      );

      log("studyID: $studyId");

      final teamProvider = context.read<ChecklistItemProvider>();
      // await teamProvider.refresh(studyId, widget.selectedDate);
      _quitEditing();


    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("생성 실패: $e");
      }
      log("체크리스트 생성 실패?: $e");
    }
  }

  Future<void> _updateChecklistItemContent(item, String value) async {
    _finishEditing(item, updatedContent: value);

    try {
      //TODO provider 활성화
      final provider = context.read<PersonalChecklistProvider>();
      // await provider.updateContent(item.id, value);
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

  // ==================== UI Actions ====================

  void _showItemOptions(item, int studyId) {
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

  void _finishEditing(item, {required String updatedContent}) {
    setState(() {
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
}