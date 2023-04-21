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
    final dadosLogin = await getData(snapshot.docs[0].id, 'users');
    if (dadosLogin['senha'] == senha) {
      final loginId = dadosLogin["id"];

      final userId = await FirebaseFirestore.instance
          .collection("prefeituras/${loginId}/users/")
          .where('cpf', isEqualTo: cpf)
          .limit(1)
          .get();

      final data = await getUserData(userId.docs[0].id, loginId);
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

getUserData(id, loginId) async {
  final users = await FirebaseFirestore.instance
      .collection('prefeituras/${loginId}/users/')
      .doc(id)
      .get()
      .then((value) => value.data());

  if (users != null) {
    return {
      'nome': users['nome'],
      'cpf': users['cpf'],
      'corAvatar': users['corAvatar'],
      'curso': users['cursoAluno'],
      'faculdade': users['faculdade'],
      'telefone': users['telefone'],
      'senha': users['senha'],
    };
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
