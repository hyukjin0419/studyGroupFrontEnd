import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/providers/study_provider.dart';
import 'package:study_group_front_end/screens/study_query/widgets/floating_menu_overlay.dart';
import 'package:study_group_front_end/screens/study_query/widgets/study_card.dart';
import 'package:study_group_front_end/util/color_converters.dart';
import 'package:study_group_front_end/util/study_toggle_button.dart';

class StudiesScreen extends StatefulWidget {
  const StudiesScreen({super.key});

  @override
  State<StudiesScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudiesScreen> {
  bool isProgressSelected = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(5,0,8,0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.asset(
                'assets/logo/owl2.png',
                height: 40,
              ),
              SizedBox(width: 5),
              Text(
                "Sync Mate",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: hexToColor("0xFF1B325E"),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5,10,8,0),
            child: StudyToggleButton(
                isProgress: isProgressSelected,
                onToggle: (bool isProgress) {
                  setState(() {
                    // log("pressed $isProgress");
                    isProgressSelected = isProgress;
                    // log("pressed $isProgressSelected");
                  });
            }),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final provider = context.read<StudyProvider>();
          await provider.getMyStudies();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12,12,12,0),
          child: Consumer<StudyProvider> (
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final allStudies = provider.studies;

              final filteredStudies = allStudies
                  .where((s) => isProgressSelected
                  ? s.status == StudyStatus.PROGRESSING
                  : s.status == StudyStatus.DONE)
                  .toList();

              if (filteredStudies.isEmpty) {
                return Center(
                  child: Text(
                    isProgressSelected
                        ? "진행중인 스터디가 없습니다."
                        : "완료된 스터디가 없습니다.",
                  ),
                );
              }

              return ReorderableGridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 10 / 10,
                ),
                itemCount: filteredStudies.length,
                itemBuilder: (context, index) {
                  final study = filteredStudies[index];
                  return StudyCard(
                    key: ValueKey(study.id),
                    study: study
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  provider.updateStudiesOrder(oldIndex, newIndex);
                },

                dragWidgetBuilder: (index, child) {
                  return Material(
                    type: MaterialType.transparency,
                    elevation: 6,
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.hardEdge,
                    child: child,
                  );
                },
              );
            }
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        height: 50,
        width: 50,
        child: FloatingActionButton(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const FloatingMenuOverlay(),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          backgroundColor: hexToColor("0xFF93DAF8"),
          foregroundColor: Colors.white,
          child: Icon(
            Icons.add_rounded,
            size: 38,
          ),
        ),
      ),
    );
  }
}
