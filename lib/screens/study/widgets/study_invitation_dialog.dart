import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_group_front_end/api_service/study_join_api_service.dart';
import 'package:study_group_front_end/providers/study_provider.dart';

class InvitationDialog extends StatelessWidget {
  final int invitationId;
  final String title;
  final String body;
  final StudyProvider studyProvider;

  const InvitationDialog({
    super.key,
    required this.invitationId,
    required this.title,
    required this.body,
    required this.studyProvider
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => _decline(context),
          child: const Text("거절"),
        ),
        ElevatedButton(
          onPressed: () => _accept(context),
          child: const Text("수락"),
        ),
      ],
    );
  }

  void _accept(BuildContext context) async {
    try{
      final studyId = await StudyJoinApiService().acceptInvitation(invitationId);

      log("studyId: $studyId");

      await studyProvider.getMyStudies();

      log("pressed accept");

      Navigator.of(context).pop();
      context.push("/studies/$studyId");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("수락에 실패했습니다. 다시 시도해쥇요. $e")),
      );
    }
  }

  void _decline(BuildContext context) async {
    try{
      await StudyJoinApiService().declineInvitation(invitationId);

      log("pressed decline");

      Navigator.of(context).pop();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("거절에 실패했습니다. 다시 시도해쥇요. $e")),
      );
    }
  }
}
