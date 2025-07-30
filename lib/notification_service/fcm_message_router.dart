import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:study_group_front_end/notification_service/study_invitation_handler.dart';

class FcmMessageRouter {
  static void route(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];

    log("Routing FCM message: $data");

    switch(type) {
      case 'STUDY_INVITATION':
        StudyInvitationHandler.handleInvitationMessage(data);
        break;

      default:
        log("알 수 없는 FCM message type", name: "_handleFcmMessgae");
    }
  }
}