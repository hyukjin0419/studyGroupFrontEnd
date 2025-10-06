import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/providers/checklist_item_provider.dart';
import 'package:study_group_front_end/screens/checklist/common/tile/parts/customized_check_box.dart';

class ChecklistItemTile extends StatefulWidget {
  final int itemId;
  final String title;
  final bool completed;
  final Color color;
  final VoidCallback onMore;

  const ChecklistItemTile({
    super.key,
    required this.itemId,
    required this.title,
    required this.completed,
    required this.color,
    required this.onMore,
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
    _completed = widget.completed;
    _title = widget.title;
  }

  void _toggleCompleted() async {
    setState(() {
      _completed = !_completed;
    });
    try {
      final provider = context.read<ChecklistItemProvider>();
      await provider.updateChecklistItemStatus(widget.itemId);
      provider.sortChecklistGroupsByCompletedThenOrder();
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