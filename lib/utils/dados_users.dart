import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

getInfoUser() async {
  SharedPreferences shared = await SharedPreferences.getInstance();
  final dadosString = shared.getString("dados");

  final Map? dados = jsonDecode(dadosString!);
  return dados;
}

setVaribleShared(String nome, Map? dados) async {
  SharedPreferences shared = await SharedPreferences.getInstance();

  shared.setString(nome, jsonEncode(dados));
}

getListShared(String nome) async {
  SharedPreferences shared = await SharedPreferences.getInstance();

  var data = shared.getStringList(nome);

  if (data != null) {
    final mapList = data.map((jsonString) {
      return jsonDecode(jsonString);
    }).toList();

    return mapList;
  }
}

setListShared(String nome, List lista) async {
  SharedPreferences shared = await SharedPreferences.getInstance();

  final encodedlista = lista.map((item) => jsonEncode(item)).toList();

  shared.setStringList(nome, encodedlista);
}
