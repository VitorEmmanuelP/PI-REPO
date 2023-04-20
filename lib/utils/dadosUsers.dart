import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

getInfoUser() async {
  SharedPreferences shared = await SharedPreferences.getInstance();
  final dadosString = shared.getString("dados");

  final Map? dados = jsonDecode(dadosString!);
  print('ADWADWAD DADOS ${dados.runtimeType}');
  return dados;
}
