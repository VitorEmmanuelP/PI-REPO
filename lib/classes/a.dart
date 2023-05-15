import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pi/utils/dados_users.dart';

Future<void> sendFcmMessage() async {
  // final b = [
  //   'cf-YEU3hT1ml2Ir4Whsaar:APA91bFz26S4aRQC30qQt8yjJ1UYqR5kUmw1-xaAgmIVS0RJVZmtu8AqXNdfoJTQ65nMEzU5gZglu0S9gYDmk2M_kGfOTcTg_zxiX1jIz4oDQEzmQVGPh0u7osO24TrfoVn-lLMj26AF',
  //   'et3fJ_sRT-2dL12DzCw7Vl:APA91bHN6luXxaZDKCRWjDm0DsigZKA7p4Kaz-dGBDNT4_zL_L0cBTSY7rPtBZ1GETZ2c-PPUcaDZkm2y44PGjRQ3CEgNRxOLefLEpOqaD5VYYJ5GcZ7gHx_y8k1bvsK6i2Ybb5PoqU0',
  //   'cgrlb2owRlqvHbHoqrnq6d:APA91bE24BynbWptOKgOQt_GBOm67B7zba1yeIvCO64aEZcWxfc7okqvdM6bMUUeNQpQn4paMNsPrEsN1IcZZ_wD3q5zzOosQXywI5C-Vm19lur6nZcLQXyePz1KNIPpA08C2NSaXQ-P'
  // ];
  final alunosToken = await getListUsers();

  for (var token in alunosToken) {
    const String serverKey =
        'AAAAZ5VGxg0:APA91bGzRRLoInoYP170N8P9pklr-MDReQ8kxFcjO0jvac4nwBjjya7Utpwrj8-yniZA9qLQIPy8pqCucSfvQ1m4jj4D8t5kXXpG6HXqoTMAbzidPXcbltC6dwrAZ0ByAyMJMyzw36qk'; // substitua pelo seu server key
    const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

    final Map<String, dynamic> message = <String, dynamic>{
      'notification': <String, dynamic>{
        'body': 'Eu sou o homem que mais da a bunda no planeta terra',
        'title': 'Test message',
      },
      'priority': 'high',
      'to': token
          .token // substitua pelo token do dispositivo que você deseja enviar a mensagem
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
