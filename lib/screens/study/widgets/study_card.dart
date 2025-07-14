import 'package:flutter/material.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/util/color_converters.dart';

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

                },
              )
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12),
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
}