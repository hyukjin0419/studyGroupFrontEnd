import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/util/color_converters.dart';
import 'package:study_group_front_end/widgets/common_bottom_sheet.dart';

class StudyCard extends StatelessWidget {
  final StudyDetailResponse study;

  const StudyCard({super.key, required this.study});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: hexToColor(study.personalColor),
      child: Stack(
        children: [
          Positioned(
              top: 2,
              right: -8,
              child: IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () {
                  _showCustomizedModal(context);
                },
              )
          ),
          // const SizedBox(height: 16),
          // const Spacer(),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(study.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 6,
                    child:
                    LinearProgressIndicator(
                      value: study.progress,
                      backgroundColor: Colors.white38,
                      color: Colors.white
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text('${(study.progress * 100).round()}%', style: const TextStyle(color: Colors.white, fontSize: 12)),
                const Spacer(),
                Text(study.dueDate.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(study.status, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomizedModal(BuildContext context) {
    showCommonBottomSheet(context,
      [
        BottomSheetItem(
            icon: Icons.info_outline,
            text: '정보 보기',
            onTap: () {
              log('정보보기 클릭',name: 'StudyCard');
            }
        ),
        BottomSheetItem(
            icon: Icons.edit,
            text: '수정',
            onTap: () {
              log('수정 클릭',name: 'StudyCard');
            }
        ),
        BottomSheetItem(
            icon: Icons.delete,
            text: '삭제',
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: () {
              log('삭제 클릭',name: 'StudyCard');
            }
        ),
      ]
    );
  }
}





















