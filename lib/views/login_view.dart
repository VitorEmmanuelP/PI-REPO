import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:pi/constants/routes.dart';
import 'package:pi/services/auth_expection.dart';
import 'package:pi/utils/dados_users.dart';
import 'package:pi/utils/show_error_message.dart';
import 'package:pi/utils/validador_login.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _user;
  late final TextEditingController _password;
  late final Map dados;

  @override
  void initState() {
    _user = TextEditingController();
    _password = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _user.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar(),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 300,
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 300,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: _user,
                    decoration: estiloTextField("Username"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: _password,
                    decoration: estiloTextField("Password"),
                  ),
                ),
                OutlinedButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      final cpf = _user.text;
                      final password = _password.text;

                      try {
                        final dadosUser =
                            await validarLogin(cpf, password, getData);

                        if (dadosUser != null) {
                          saveUserOrPrefeitura('dados', dadosUser);

                          FirebaseAuth auth = FirebaseAuth.instance;

                          await auth.signInAnonymously();

                          mudarTela(dadosUser);
                        }
                      } on UserNotFound {
                        await showErrorMessage(context, 'UserNotFOund');
                      } on WrongPassword {
                        await showErrorMessage(context, 'Wrong Passowrd');
                      } on EmptyFields {
                        await showErrorMessage(context, 'Empty Fields');
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      side: const BorderSide(color: Colors.black, width: 1),
                    ),
                    child: const Text("Login")),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(esqueceSenha);
                    },
                    child: const Text('Esquici minha senha'))
              ],
            ),
          ),
        ),
      ),
    );
  }

  mudarTela(dados) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(homeRoute, (route) => false, arguments: dados);
  }

  getData(id, from) async {
    if (from == 'users') {
      return await getUsersData(id);
    } else if (from == 'prefeitura') {
      return await getPrefeituraData(id);
    }
  }

  getUsersData(id) async {
    final users = await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .get()
        .then((value) => value.data());

    if (users != null) {
      return {
        'cpf': users['cpf'],
        'senha': users['senha'],
        'id': users['id'],
        'idPrefeitura': users['idPrefeitura'],
      };
    }
  }

  Future getPrefeituraData(id) async {
    final prefeitura = await FirebaseFirestore.instance
        .collection('prefeituras')
        .doc(id)
        .get()
        .then((value) => value.data());

    if (prefeitura != null) {
      return {
        'nome': prefeitura['nome'],
        'senha': prefeitura['senha'],
        'id': prefeitura['id'],
        'status': prefeitura['status'],
      };
    }
  }

  InputDecoration estiloTextField(String label) {
    return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        enabledBorder: fazerBorda(),
        focusedBorder: fazerBorda());
  }

  OutlineInputBorder fazerBorda() {
    return OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.black),
      borderRadius: BorderRadius.circular(10),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        "Login",
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }
}
