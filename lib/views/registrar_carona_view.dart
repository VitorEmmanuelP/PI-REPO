import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pi/models/user_data.dart';

import '../models/bus_data.dart';
import '../utils/check_internet.dart';
import '../utils/styles.dart';
import '../widgets/app_bar.dart';

class RegistrarCaronaView extends StatefulWidget {
  const RegistrarCaronaView({super.key});

  @override
  State<RegistrarCaronaView> createState() => _RegistrarCaronaViewState();
}

class _RegistrarCaronaViewState extends State<RegistrarCaronaView> {
  late final TextEditingController _nome;
  late final TextEditingController _telefone;

  UserData? dados;
  BusData? onibusInfo;
  String formattedDate = '';

  @override
  void initState() {
    _nome = TextEditingController();
    _telefone = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _nome.dispose();
    _telefone.dispose();

    super.dispose();
  }

  var nomesError = false;
  var telefoneError = false;

  bool? checkBoxIda = false;
  bool? checkBoxVolta = false;

  @override
  Widget build(BuildContext context) {
    final List? args = ModalRoute.of(context)?.settings.arguments as List?;
    DateTime now = DateTime.now();
    if (args != null) {
      dados = args[0];
      onibusInfo = args[1];

      formattedDate = DateFormat('dd-MM-yyyy').format(now);
    }
    final maskFormatTelef = MaskTextInputFormatter(
        mask: '(##)#####-####', filter: {"#": RegExp(r'[0-9]')});

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: scaffoldColor,
        appBar: appBar("Registrar Carona"),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 200,
                child: Image.asset("assets/images/avatar.jpg"),
              ),
              SizedBox(
                child: Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: TextField(
                          controller: _nome,
                          decoration: estiloTextField("Nome",
                              erro: nomesError,
                              msg: "Digite pelo menos o Nome e Sobrenome"),
                          onChanged: (value) {
                            if (nomesError) {
                              setState(() {
                                nomesError = false;
                              });
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: TextField(
                          controller: _telefone,
                          keyboardType: TextInputType.number,
                          inputFormatters: [maskFormatTelef],
                          decoration: estiloTextField(
                            "Telefone",
                            erro: telefoneError,
                            msg: "Digite um telefone valido",
                          ),
                          onChanged: (value) {
                            if (telefoneError) {
                              setState(() {
                                telefoneError = false;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                checkButtons(tipo: "volta"),
                checkButtons(tipo: "ida"),
              ]),
              Padding(
                padding: const EdgeInsets.only(
                    top: 30, bottom: 20.0, right: 20, left: 20),
                child: ElevatedButton(
                    style: styleButton(),
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      bool isConnected = await checkInternetConnection();

                      if (isConnected) {
                        final nome = _nome.text;
                        final telefone =
                            maskFormatTelef.unmaskText(_telefone.text);
                        String? status;
                        if (checkBoxIda! && checkBoxVolta!) {
                          status = "Ida e Volta";
                        } else if (checkBoxIda!) {
                          status = "Ida";
                        } else if (checkBoxVolta!) {
                          status = "Volta";
                        }

                        validarRegistros(nome, telefone);

                        if (checarErros()) {
                          final usera = FirebaseFirestore.instance
                              .collection(
                                  "prefeituras/${dados!.idPrefeitura}/onibus/${dados!.idOnibus}/listaPresensa/")
                              .doc(formattedDate);

                          var data = await usera
                              .get()
                              .then((value) => value.data()) as Map;

                          if (int.parse(data['numerosAlunos']) <
                              int.parse(onibusInfo!.numeroVagas)) {
                            await FirebaseFirestore.instance
                                .collection(
                                    "prefeituras/${dados!.idPrefeitura}/onibus/${dados!.idOnibus}/listaPresensa/$formattedDate/alunos")
                                .doc(nome)
                                .set({
                              "nome": nome,
                              "data": formattedDate,
                              "telefone": telefone,
                              "status": status,
                            });

                            usera.set({
                              'nome': formattedDate,
                              'numerosAlunos':
                                  "${int.parse(data['numerosAlunos'].toString()) + 1}"
                            });

                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              behavior: SnackBarBehavior.fixed,
                              duration: Duration(milliseconds: 500),
                              backgroundColor: Colors.red,
                              content: Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Center(
                                    child: Text(
                                  "O onibus esta cheio",
                                )),
                              ),
                            ));
                          }
                        }

                        //print(validarNumeroCelular(telefone));
                      }
                    },
                    child: const Text("Adicionar carona")),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool checarErros() {
    if (!nomesError && !telefoneError) {
      return true;
    } else {
      return false;
    }
  }

  void validarRegistros(String nome, String telefone) {
    nome = nome.trim();
    List<String> nomes = nome.split(' ');

    setState(() {
      if (nomes.isEmpty || nomes[0] == '') {
        nomesError = true;
      }

      if (!validarNumeroCelular(telefone)) {
        telefoneError = true;
      }
      if (!erroCheckBox()) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.fixed,
          duration: Duration(milliseconds: 500),
          backgroundColor: Colors.red,
          content: Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Center(
                child: Text(
              "Selecione pelo menos uma das alternativas",
            )),
          ),
        ));
      }
    });
  }

  bool validarNumeroCelular(String numero) {
    final RegExp regex = RegExp(r'^[1-9]{2}[0-9]{9}$');
    return regex.hasMatch(numero);
  }

  erroCheckBox() {
    if (checkBoxIda == false && checkBoxVolta == false) {
      return false;
    } else {
      return true;
    }
  }

  Center checkButtons({String? tipo}) {
    if (tipo == 'ida') {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Checkbox(
                  value: checkBoxIda,
                  onChanged: (newValue) {
                    setState(() {
                      checkBoxIda = newValue;
                    });
                  },
                ),
                Row(
                  children: const [
                    Text('O aluno vai ir'),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Checkbox(
                  value: checkBoxVolta,
                  onChanged: (newValue) {
                    setState(() {
                      checkBoxVolta = newValue;
                    });
                  },
                ),
                Row(
                  children: const [
                    Text('O aluno vai voltar'),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}
