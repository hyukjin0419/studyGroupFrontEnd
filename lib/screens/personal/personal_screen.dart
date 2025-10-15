import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/providers/personal_checklist_provider.dart';

class PersonalScreen extends StatefulWidget {
  const PersonalScreen({super.key});

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Checklist')),
      body: Consumer<PersonalChecklistProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.personalChecklists.isEmpty) {
            return const Center(child: Text('체크리스트가 없습니다.'));
          }

          final List<ChecklistItemDetailResponse> items = provider.personalChecklists;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    item.completed ? Icons.check_circle : Icons.circle_outlined,
                    color: item.completed ? Colors.green : Colors.grey,
                  ),
                  title: Text(item.content),
                  subtitle: Text(
                    '마감일: ${item.targetDate.toString().split("T").first}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
