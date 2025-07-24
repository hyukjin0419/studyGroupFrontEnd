import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:study_group_front_end/screens/study/widgets/create_study_dialog.dart';
import 'package:study_group_front_end/screens/widgets/custom_bottom_navigation_bar.dart';

class FloatingMenuOverlay extends StatelessWidget {
  const FloatingMenuOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),

          ),
        Positioned(
            right:16,
            bottom: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                    style:ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.group_add),
                    label: const Text("팀 생성하기"),
                    onPressed: (){
                      Navigator.of(context).pop();
                      showDialog(
                          context: context,
                          builder: (_) => const CreateStudyDialog(),
                      );
                    },
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.group),
                  label: const Text("팀 참여하기"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // TODO: 참여 다이얼로그 띄우기
                  },
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close),
                )
              ],
            ),
        ),
      ],
    );
  }
}