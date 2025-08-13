import 'package:flutter/material.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/screens/checklist/widget/checklist_item_tile.dart';
import 'package:study_group_front_end/screens/checklist/widget/member_header_chip.dart';
import 'package:study_group_front_end/util/color_converters.dart';

class MemberChecklistGroupView extends StatefulWidget {
  final List<MemberChecklistGroupVM> groups;
  final StudyDetailResponse study;

  const MemberChecklistGroupView({
    super.key,
    required this.groups,
    required this.study
  });

  @override
  State<MemberChecklistGroupView> createState() => _MemberChecklistGroupViewState();
}

class _MemberChecklistGroupViewState extends State<MemberChecklistGroupView> {
  int? editingMemberId;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(22, 8, 16, 24),
      itemCount: widget.groups.length,
      separatorBuilder: (_, __) => const SizedBox.shrink(),
      itemBuilder: (context, i) {
        final g = widget.groups[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MemberHeaderChip(
              name: g.memberName,
              color: hexToColor(widget.study.personalColor),
              onAddPressed: (){
                setState(() {
                  editingMemberId = g.memberId;
                  _controller.text = "";
                  Future.delayed(Duration.zero, () => _focusNode.requestFocus());

                });
              },
            ),
            const SizedBox(height: 10),
            ...g.items.map((it) =>
              ChecklistItemTile(
                title: it.title,
                completed: it.completed,
                color: hexToColor(widget.study.personalColor),
                onMore:() {}
              ),

            )
          ],
        );
      }

    );
  }
}


class MemberChecklistGroupVM{
  final int memberId;
  final String memberName;
  final List<MemberChecklistItemVM> items;
  const MemberChecklistGroupVM({
    required this.memberId,
    required this.memberName,
    required this.items
  });
}

class MemberChecklistItemVM{
  final String title;
  final bool completed;
  const MemberChecklistItemVM({
    required this.title,
    required this.completed,
  });
}