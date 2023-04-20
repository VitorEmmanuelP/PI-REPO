import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_expection.dart';

Future validarLogin(String cpf, String senha, Function getData) async {
  if (cpf.isEmpty && senha.isEmpty) throw EmptyFields();

  var dados = await checkarBancoPrefeitura(cpf, senha, getData);

  if (dados == false) {
    dados = await checkarBancoUser(cpf, senha, getData);

    if (dados == false) {
      throw UserNotFound();
    } else if (dados == 'wrong-password') {
      throw WrongPassword();
    } else {
      return dados;
    }
  } else if (dados == 'wrong-password') {
    throw WrongPassword();
  } else {
    return dados;
  }
}

checkarBancoUser(cpf, senha, getData) async {
  final snapshot = await FirebaseFirestore.instance
      .collection("users")
      .where('cpf', isEqualTo: cpf)
      .limit(1)
      .get();

  if (snapshot.size > 0) {
    final data = await getData(snapshot.docs[0].id, 'users');

    if (data['senha'] == senha) {
      return data;
    } else {
      return 'wrong-password';
    }
  } else {
    return false;
  }
}

checkarBancoPrefeitura(nome, senha, getData) async {
  final snapshot = await FirebaseFirestore.instance
      .collection("prefeituras")
      .where('nome', isEqualTo: nome)
      .limit(1)
      .get();

  if (snapshot.size > 0) {
    final data = await getData(snapshot.docs[0].id, 'prefeitura');

    if (data['senha'] == senha) {
      return data;
    } else {
      return 'wrong-password';
    }
  } else {
    return false;
  }
}

Future<bool> checkInternetConnection() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  } on SocketException catch (_) {
    return false;
  }
}
