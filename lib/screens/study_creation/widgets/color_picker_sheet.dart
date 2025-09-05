import 'package:flutter/material.dart';
import 'package:study_group_front_end/util/Palette.dart';

class ColorPickerSheet extends StatelessWidget {
  const ColorPickerSheet({
    super.key,
    required this.selected,
  });

  final List<Color> palette = AppColors.palette;
  final Color selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withOpacity(0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.fromLTRB(23.5,30,23.5,0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                //가로에 56픽셀이 몇개 들어가는가?
                //clamp는 계산결과를 최소 ~ 최대 값 범위 안에 가둔다.
                final cross = (constraints.maxWidth ~/ 56).clamp(4, 5);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: palette.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cross,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (_, i) {
                    final color = palette[i];
                    final isSelected = color == selected;
                    return InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () => Navigator.of(context).pop<Color>(color),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          if (isSelected)
                            const Positioned(
                              top: 6,
                              left: 6,
                              child: CircleAvatar(
                                radius: 10,
                                child: Icon(Icons.check, size: 14),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
