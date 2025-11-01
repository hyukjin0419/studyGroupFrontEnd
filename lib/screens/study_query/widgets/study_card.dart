import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/providers/me_provider.dart';
import 'package:study_group_front_end/providers/study_card_provider.dart';
import 'package:study_group_front_end/providers/study_provider.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/dto/study/update/study_update_request.dart';
import 'package:study_group_front_end/screens/study_query/widgets/dialog/study_join_code_qr_dialog.dart';
import 'package:study_group_front_end/screens/study_query/widgets/modal/study_detail_modal.dart';
import 'package:study_group_front_end/util/color_converters.dart';
import 'package:study_group_front_end/widgets/common_bottom_sheet.dart';

class StudyCard extends StatelessWidget {
  final StudyDetailResponse study;

  const StudyCard({super.key, required this.study});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:(){
        context.push(
          '/studies/${study.id}/checklists',
          extra: study,
        );
      },
      child: Consumer<StudyCardProvider>(
        builder: (context, provider, _){
          final progress = provider.getProgress(study.id);
          final status = provider.getProgressStatus(study);
          final dueLabel = provider.getDueDateLabel(study);

          return Card(
            elevation: 0,
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
                      showStudyDetailModal(context: context, study: study);
                    },
                  )
                ),
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
                            value: progress,
                            backgroundColor: Colors.white38,
                            color: Colors.white
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${(progress * 100).round()}%', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      const Spacer(),
                      Text(dueLabel.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      Text(status, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
