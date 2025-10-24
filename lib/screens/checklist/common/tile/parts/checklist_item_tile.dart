import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/providers/checklist_item_provider.dart';
import 'package:study_group_front_end/providers/personal_checklist_provider.dart';
import 'package:study_group_front_end/screens/checklist/common/tile/parts/customized_check_box.dart';

enum ChecklistContext{
  TEAM,
  PERSONAL,
}

class ChecklistItemTile extends StatefulWidget {
  final ChecklistItemDetailResponse item;
  final Color color;
  final VoidCallback onMore;
  final ChecklistContext context;

  const ChecklistItemTile({
    super.key,
    required this.item,
    required this.color,
    required this.onMore,
    required this.context,
  });

  @override
  State<ChecklistItemTile> createState() => _ChecklistItemTileState();
}

class _ChecklistItemTileState extends State<ChecklistItemTile> {
  late bool _completed;
  late String _title;

  @override
  void initState() {
    super.initState();
    _completed = widget.item.completed;
    _title = widget.item.content;
  }

  @override
  void didUpdateWidget(ChecklistItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // props 변경시 로컬 상태 동기화
    if (oldWidget.item.completed != widget.item.completed) {
      setState(() {
        _completed = widget.item.completed;
      });
    }
    if (oldWidget.item.content != widget.item.content) {
      setState(() {
        _title = widget.item.content;
      });
    }
  }

  void _toggleCompleted() async {
    setState(() {
      _completed = !_completed;
    });
    try {
      log("id? ${widget.item.id}");
      final provider = context.read<ChecklistItemProvider>();
      final personalProvider = context.read<PersonalChecklistProvider>();

      if (widget.context == ChecklistContext.TEAM){
        await provider.updateChecklistItemStatus(widget.item);
      } else {
        // await personalProvider.updateChecklistItemStatus(widget.itemId, widget.studyId);
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("체크리스트 content 업데이트 실패: $e")),
      );
      log("체크리스트 content 업데이트 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.fromLTRB(10,0,0,0),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: _toggleCompleted,
            child: CustomizedCheckBox(
              color: widget.color,
              completed: _completed
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: widget.onMore),
        ],
      ),
    );
  }
}