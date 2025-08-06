import 'package:flutter/material.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/util/color_converters.dart';

class StudyHeaderCard extends StatelessWidget {
  final StudyDetailResponse study;

  const StudyHeaderCard({super.key, required this.study});

  @override
  Widget build(BuildContext context) {
    final color = hexToColor(study.personalColor);
    final dDay = study.dueDate.difference(DateTime.now()).inDays;
    final progress = (study.progress >= 0 && study.progress <= 1) ? study.progress : 0.0;
    
    return
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: color,
            width: 1,
          ),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20,15,20,20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    study.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Icon(
                    Icons.more_vert,
                    size: 20,
                  )
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child:LinearProgressIndicator(
                      value: study.progress,
                      color: color,
                      backgroundColor: Colors.grey[60],
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Text('${(study.progress * 100).round()}%', style: const TextStyle(color: Colors.black87, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "D-${dDay > 0 ? dDay : 0}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    study.status ?? "미정",
                    style: Theme.of(context)
                      .textTheme
                      .bodySmall
                  ),
                ],
              )
            ],
          ),
        )
            ),
      );
  }
}