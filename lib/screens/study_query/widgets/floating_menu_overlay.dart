import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_group_front_end/util/color_converters.dart';

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
            bottom: 91,
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
                      context.push('/studies/create');
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
                    context.push('/studies/join');
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  width: 50,
                  child: FloatingActionButton(
                    onPressed: () => Navigator.of(context).pop(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    backgroundColor: hexToColor("0xFF93DAF8"),
                    foregroundColor: Colors.white,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 38,
                    ),
                  ),
                )
              ],
            ),
        ),
      ],
    );
  }
}