import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendFcmMessage(alunosToken) async {
  for (var data in alunosToken) {
    final token = data.data();
    print(token['nome']);
    print(token['token']);
    if (token['token'] != '') {
      const String serverKey =
          'AAAAZ5VGxg0:APA91bGzRRLoInoYP170N8P9pklr-MDReQ8kxFcjO0jvac4nwBjjya7Utpwrj8-yniZA9qLQIPy8pqCucSfvQ1m4jj4D8t5kXXpG6HXqoTMAbzidPXcbltC6dwrAZ0ByAyMJMyzw36qk'; // substitua pelo seu server key
      const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

      final Map<String, dynamic> message = <String, dynamic>{
        'notification': <String, dynamic>{
          'body': 'Uma nova lista foi criada, corra para marca preseça',
          'title': 'Ola ${token['nome']}',
        },
        'priority': 'high',
        'to': token[
            'token'] // substitua pelo token do dispositivo que você deseja enviar a mensagem
      };
      final http.Response response = await http.post(
        Uri.parse(fcmUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('Mensagem enviada com sucesso!');
      } else {
        print(
            'Falha ao enviar mensagem. Código de status HTTP: ${response.statusCode}');
      }
    }
  }
}
