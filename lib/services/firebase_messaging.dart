import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pi/services/notificantion_service.dart';
import 'package:pi/utils/dados_users.dart';

class FirebaseMessagingService {
  Future<void> initialize() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    getDeviceFirebaseToken();
    _onMessage();
  }

  getDeviceFirebaseToken() async {
    final token = await FirebaseMessaging.instance.getToken();

    await savetoken(token);
  }

  _onMessage() {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        NotificationServices.showNotification(
            title: notification.title, body: notification.body);
      }
    });
  }
}






























// import 'package:firebase_messaging/firebase_messaging.dart';

// import 'notificantion_service.dart';

// class FirebaseMessagingService {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

//   Future<void> initialize() async {
//     await _firebaseMessaging.requestPermission();
//     FirebaseMessaging.onMessage.listen(_onMessageReceived);
//     FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);
//   }

//   void _onMessageReceived(RemoteMessage message) async {
//     await NotificationServices.showNotification(
//       title: message.notification?.title,
//       body: 'dawd',
//     );
//   }

//   void _onMessageOpened(RemoteMessage message) {
//     print('Mensagem aberta: ${message.notification?.title}');
//   }
// }

// // class MyFirebaseMessagingService extends FirebaseMessagingService {
// //   @override
// //   Future<void> onMessageReceived(RemoteMessage message) async {
// //     super.onMessageReceived(message);

// //     // Obtenha os dados da mensagem
// //     final data = message.data;

// //     // Obtenha o título e o corpo da mensagem
// //     final notificationTitle = data['title'];
// //     final notificationBody = data['body'];

// //     // Crie a notificação local
// //     await NotificationServices.showNotification(
// //       title: notificationTitle!,
// //       body: notificationBody!,
// //       payload: data,
// //     );
// //   }
// // }
