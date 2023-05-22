import 'dart:convert';

import 'package:pi/models/bus_data.dart';
import 'package:pi/models/prefeitura_data.dart';
import 'package:pi/models/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveListModels(String nome, List<dynamic> listaUsers) async {
  final prefs = await SharedPreferences.getInstance();

  final List<String> encodedlista =
      listaUsers.map((user) => jsonEncode(user.toJson())).toList();
  await prefs.setStringList(nome, encodedlista);
}

Future<List<UserData>> getListUsers() async {
  final prefs = await SharedPreferences.getInstance();
  final userListJson = prefs.getStringList('listaAlunos') ?? [];
  return userListJson
      .map((jsonString) => UserData.fromJson(jsonDecode(jsonString)))
      .toList();
}

Future<List<BusData>> getListOnibus() async {
  final prefs = await SharedPreferences.getInstance();
  final userListJson = prefs.getStringList('listaOnibus') ?? [];

  return userListJson
      .map((jsonString) => BusData.fromJson(jsonDecode(jsonString)))
      .toList();
}

Future<void> saveUserOrPrefeitura(String nome, user) async {
  final prefs = await SharedPreferences.getInstance();

  prefs.setString(nome, jsonEncode(user.toJson()));
  //await prefs.reload();
}

Future<dynamic> getUser() async {
  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString('dados');
  if (userJson != null) {
    final userMap = json.decode(userJson);

    if (userMap['status'] == 'aluno' || userMap['status'] == 'cordenador') {
      final b = UserData.fromJson(userMap);
      return b;
    } else {
      return PrefeituraData.fromJson(userMap);
    }
  } else {
    return null;
  }
}

Future<void> savetoken(String? token) async {
  final prefs = await SharedPreferences.getInstance();

  prefs.setString('token', token ?? '');
  //await prefs.reload();
}

Future<dynamic> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  return token;
}
