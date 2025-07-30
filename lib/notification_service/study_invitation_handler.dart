import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:study_group_front_end/screens/study/widgets/study_invitation_dialog.dart';
import 'package:study_group_front_end/util/navigator_key.dart';

class StudyInvitationHandler{
  static void handleInvitationMessage(Map<String, dynamic> data) {
    try {
      final invitationId = int.parse(data['invitationId']);
      final title = data['title'];
      final body = data['body'];

      final context = navigatorKey.currentState?.overlay?.context;

      if (context == null) {
        log("context가 null입니다. Dialog를 띄울 수 없습니다.");
        return;
      }

      if (ModalRoute
          .of(context)
          ?.isCurrent == false) {
        log("중복 Dialog 생성 방지");
        return;
      }

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) =>
              InvitationDialog(
                invitationId: invitationId,
                title: title,
                body: body,
              )
      );
    } catch (e) {
      log("handleInvitationMessage 처리 중 오류: $e");
    }
  }
}