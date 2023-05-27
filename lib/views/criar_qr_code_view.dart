import 'dart:math';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pi/constants/routes.dart';
import 'package:pi/models/payload_pix.dart';
import 'package:pi/models/user_data.dart';
import 'package:pi/utils/dados_users.dart';
import 'package:pi/utils/show_error_message.dart';
import 'package:pi/utils/validadores_genericos.dart';

import '../utils/styles.dart';

class Pix extends StatefulWidget {
  const Pix({super.key});

  @override
  State<Pix> createState() => _PixState();
}

class _PixState extends State<Pix> {
  late final TextEditingController _cpf;
  late final TextEditingController _valor;
  late List<String> hintTexts;
  late Stream<String> hintTextStream;

  UserData? user;
  String? randomkey;

  bool cpfError = false;
  bool valorError = false;
  @override
  void initState() {
    super.initState();
    final List<String> hintTexts = [
      'Digite um cpf',
      'Digite numero de telefone',
      'Digite numero de gmail',
      'Digite uma chave aletoria'
    ];
    hintTextStream = Stream<String>.periodic(
      const Duration(seconds: 2),
      (count) => hintTexts[count % hintTexts.length],
    ).takeWhile((value) => true);

    loadData();
    _cpf = TextEditingController();
    _valor = TextEditingController();
  }

  @override
  void dispose() {
    _cpf.dispose();
    _valor.dispose();

    super.dispose();
  }

  String data = '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: scaffoldColor,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
              child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Crie um QR Code Pix',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Digite uma chave pix e o valor desejado",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              StreamBuilder<String>(
                  stream: hintTextStream,
                  builder: (context, snapshot) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: TextField(
                        controller: _cpf,
                        decoration: estiloTextField(
                          "Chave pix",
                          erro: cpfError,
                          msg: "Digite uma chave pix valida.",
                          placeholder: snapshot.data,
                        ),
                        onChanged: (value) {
                          setState(() {
                            cpfError = false;
                          });
                        },
                      ),
                    );
                  }),
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: _valor,
                  keyboardType: TextInputType.number,
                  decoration: estiloTextField(
                    "Valor",
                    erro: valorError,
                    msg: "Digite um valor valido",
                  ),
                  onChanged: (value) {
                    if (valorError) {
                      setState(() {
                        valorError = false;
                      });
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (user!.idOnibus == '') {
                          showErrorMessage(context,
                              "E preciso estar cadrastado em um onibus para criar Qr Codes Pix");
                        } else {
                          String cpfText = _cpf.text;
                          final valor = _valor.text;

                          validarRegistros(cpfText, valor);

                          if (validarNumeroCelular(cpfText) &&
                              !isCPFValid(cpfText)) {
                            cpfText = '+55$cpfText';
                          }
                          if (checarErros()) {
                            final payload = PayloadPix(
                              pixKey: cpfText,
                              description: "Passagem do onibus",
                              merchantName: user!.nome,
                              merchantCity: 'Minas Gerais',
                              amount: valor,
                              txId: randomkey!,
                            );
                            DateTime now = DateTime.now();

                            String formattedDateTime =
                                DateFormat('dd-MM-yyyy HH:mm').format(now);

                            await FirebaseFirestore.instance
                                .collection(
                                    "prefeituras/${user!.idPrefeitura}/onibus/${user!.idOnibus}/pagamentos")
                                .add({
                              'criador': user!.nome,
                              'idCriador': user!.id,
                              'data': formattedDateTime,
                              'status': 'pendente',
                              'valor': valor,
                              'qrcode': payload.getPayload(),
                            });

                            Navigator.of(context).pushNamed(
                                pagamentoPreviwRoute,
                                arguments: payload);
                          }
                        }
                      },
                      child: const Text("Criar"),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                              listaPagamentoPixRoute,
                              arguments: user);
                        },
                        child: const Text("Lista de QrCodes"))
                  ],
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }

  void validarRegistros(String chavePix, String valor) {
    setState(() {
      if (!isCPFValid(chavePix) &&
          !validarEmail(chavePix) &&
          !validarNumeroCelular(chavePix) &&
          !validarChaveAleatoria(chavePix)) {
        cpfError = true;
      }

      if (!validarValor(valor)) {
        valorError = true;
      }
    });
  }

  bool validarChaveAleatoria(String key) {
    final RegExp regex = RegExp(r'^[a-zA-Z0-9]{32}$');
    return regex.hasMatch(key.replaceAll("-", ""));
  }

  bool checarErros() {
    if (!cpfError && !valorError) {
      return true;
    } else {
      return false;
    }
  }

  bool validarNumeroCelular(String numero) {
    final RegExp regex = RegExp(r'^[1-9]{2}[0-9]{9}$');
    return regex.hasMatch(numero);
  }

  validarValor(valor) {
    if (valor.length <= 0) {
      return false;
    } else {
      return true;
    }
  }

  bool validarEmail(String email) {
    final RegExp regex = RegExp(r'^[\w-]+(\.[\w-]+)*@gmail\.com$');
    return regex.hasMatch(email);
  }

  loadData() async {
    user = await getUser();
    randomkey = generateRandomKey();
  }

  String generateRandomKey() {
    var random = Random();
    var now = DateTime.now();
    var key = '${now.microsecondsSinceEpoch}${random.nextInt(999999)}';
    return key;
  }
}
