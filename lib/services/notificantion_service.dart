import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class CustomNotification {
  int? id;
  String? titulo;
  String? corpo;
  String? payload;

  CustomNotification({
    required this.id,
    required this.titulo,
    required this.corpo,
    required this.payload,
  });
}

class NotificationServices {
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: "high_importance_channel",
          channelName: "Basic Notification",
          channelDescription: "Notification Channel for basic Test",
          defaultColor: const Color(0xFF9D50DD),
          importance: NotificationImportance.Max,
          channelShowBadge: false,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: "high_importance_channel_group",
          channelGroupName: "Group 1",
        )
      ],
      debug: true,
    );

    await AwesomeNotifications().isNotificationAllowed().then(
      (isAlowwed) async {
        if (!isAlowwed) {
          await AwesomeNotifications().requestPermissionToSendNotifications();
        }
      },
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReviedMethod,
    );
  }

  static Future<void> onActionReviedMethod(
      ReceivedAction receivedAction) async {
    final payload = receivedAction.payload ?? {};

    if (payload['navigate'] == 'true') {
      MyApp.navigatorKey.currentState?.pushNamed('registerAlunoRoute');
    }
  }

  static Future<void> showNotification({
    required final String? title,
    required final String? body,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final List<NotificationActionButton>? actionButton,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: "high_importance_channel",
        title: title,
        body: body,
        payload: payload,
        actionType: actionType,
        notificationLayout: notificationLayout,
      ),
      actionButtons: actionButton,
    );
  }
}
