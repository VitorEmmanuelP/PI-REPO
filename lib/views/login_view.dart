import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pi/constants/routes.dart';
import 'package:pi/services/auth_expection.dart';
import 'package:pi/utils/dados_users.dart';
import 'package:pi/utils/show_error_message.dart';
import 'package:pi/utils/validador_login.dart';

import '../utils/styles.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _cpf;
  late final TextEditingController _password;
  late final Map dados;
  bool isLoading = false;

  @override
  void initState() {
    _cpf = TextEditingController();
    _password = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _cpf.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maskFormatterCpf = MaskTextInputFormatter(
        mask: '###-###-###-##', filter: {"#": RegExp(r'[0-9]')});

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: scaffoldColor,
        appBar: appBar("Login"),
        body: Stack(
          children: [
            if (isLoading)
              Container(
                color: Colors.grey,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            SingleChildScrollView(
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
                        controller: _cpf,
                        //inputFormatters: [maskFormatterCpf],
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
                          //final cpf = maskFormatterCpf.unmaskText(_cpf.text);
                          final cpf = _cpf.text;
                          final password = _password.text;
                          setState(() {
                            isLoading = true;
                          });
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
                            await showErrorMessage(
                                context, 'O usuário não foi encontrado');
                          } on WrongPassword {
                            await showErrorMessage(context, 'Senha incorreta');
                          } on EmptyFields {
                            await showErrorMessage(
                                context, 'Não deixe um campo vazio');
                          }
                          setState(() {
                            isLoading = false;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              isLoading ? Colors.grey : Colors.blue,
                          minimumSize: const Size(200, 50),
                          side: BorderSide(
                              color: isLoading ? Colors.grey : Colors.blue,
                              width: 1),
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                              color: isLoading ? Colors.grey : Colors.white),
                        )),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed(esqueceSenha);
                              },
                              child: const Text(
                                'Esquici minha senha',
                                style: TextStyle(
                                    color: Color.fromARGB(100, 105, 105, 105)),
                              )),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
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
        'prefeituraNome': prefeitura["prefeituraNome"],
      };
    }
  }

  AppBar appBar(String text) {
    return AppBar(
      title: Text(
        text,
        style: const TextStyle(color: Colors.black),
      ),
      backgroundColor: isLoading ? Colors.grey : scaffoldColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }
}
