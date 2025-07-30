import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:study_group_front_end/notification_service/fcm_message_router.dart';
import 'package:study_group_front_end/notification_service/local_notifications_service.dart';

class FcmHandler {
  static LocalNotificationsService? localNotificationsService;

  static void onForegroundMessage(RemoteMessage message) {
    FcmMessageRouter.route(message);

    final notificationData = message.notification;
    if (notificationData != null) {
      // Display a local notification using the service
      localNotificationsService?.showNotification(
        notificationData.title,
        notificationData.body,
        message.data.toString(),
      );
    }
  }

  static void onMessageOpenedApp(RemoteMessage message){
    FcmMessageRouter.route(message);
  }
}