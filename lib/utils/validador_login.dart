import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pi/models/prefeitura_data.dart';
import 'package:pi/models/user_data.dart';
import 'package:pi/utils/dados_users.dart';
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
      final loginId = dadosLogin["idPrefeitura"];

      final userId = await FirebaseFirestore.instance
          .collection("prefeituras/$loginId/users/")
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
      return PrefeituraData(
          nome: data['nome'],
          senha: data['senha'],
          id: data['id'],
          status: data['status']);
    } else {
      return 'wrong-password';
    }
  } else {
    return false;
  }
}

getUserData(id, loginId) async {
  final user = await FirebaseFirestore.instance
      .collection('prefeituras/$loginId/users/')
      .doc(id)
      .get();

  final token = await getToken();

  user.reference.update({'token': token});

  final userdata = user.data();

  if (user != null) {
    return UserData(
        nome: user['nome'],
        cpf: user['cpf'],
        profilePic: user['profilePic'],
        data: user['data'],
        curso: user['cursoAluno'],
        faculdade: user['faculdade'],
        telefone: user['telefone'],
        senha: user['senha'],
        status: user['status'],
        id: user['id'],
        idPrefeitura: user['idPrefeitura'],
        idOnibus: user['idOnibus'],
        token: user['token'],
        qrCode: user['qrCode']);
  }
  // return {
  //   'nome': users['nome'],
  //   'cpf': users['cpf'],
  //   'profilePic': users['profilePic'],
  //   'curso': users['cursoAluno'],
  //   'faculdade': users['faculdade'],
  //   'telefone': users['telefone'],
  //   'senha': users['senha'],
  //   'status': users['status'],
  //   'id': users['id'],
  //   'idPrefeitura': users['idPrefeitura'],
  //   'idOnibus': users['idOnibus'],
  // };
  //}
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
