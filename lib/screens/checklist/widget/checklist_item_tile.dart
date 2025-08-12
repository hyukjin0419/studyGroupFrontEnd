import 'package:flutter/material.dart';
import 'package:study_group_front_end/util/color_converters.dart';

class ChecklistItemTile extends StatefulWidget {
  final String title;
  final bool completed;
  final Color color;
  final VoidCallback onMore;

  const ChecklistItemTile({
    super.key,
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

  @override
  void initState() {
    super.initState();
    _completed = widget.completed;
  }

  void _toggleCompleted() {
    setState(() {
      _completed = !_completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,//?
      padding: const EdgeInsets.fromLTRB(10,0,0,0),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: _toggleCompleted,
            child: _CustomizedCheckBox(
              color: widget.color,
              completed: _completed
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.title,
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

class _CustomizedCheckBox extends StatelessWidget {
  final Color color;
  final bool completed;
  const _CustomizedCheckBox({
    required this.completed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: completed ?  color : hexToColor("0xFFD9D9D9"),
      ),
      child: completed ? const Icon(
        Icons.check,
        size: 20,
        color: Colors.white,
      ) : null,
    );
  }
}