import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InvitationDialog extends StatelessWidget {
  final int invitationId;
  final String title;
  final String body;

  const InvitationDialog({
    super.key,
    required this.invitationId,
    required this.title,
    required this.body
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
  //   // TODO: invitationId로 수락 API 호출
  //   await InvitationApiService().accept(invitationId);
  //   Navigator.of(context).pop();
  //   // Optional: 해당 스터디 화면으로 이동
  //   context.go("/studies/$invitationId");
    log("pressed accept");

    Navigator.of(context).pop();
  }
  //
  void _decline(BuildContext context) async {
  //   // TODO: invitationId로 거절 API 호출
  //   await InvitationApiService().decline(invitationId);
    log("pressed decline");
    Navigator.of(context).pop();
  }
}
