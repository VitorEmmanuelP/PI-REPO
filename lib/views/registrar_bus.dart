import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pi/utils/show_error_message.dart';

import '../utils/check_internet.dart';
import '../utils/dados_users.dart';
import '../utils/styles.dart';
import '../widgets/app_bar.dart';

class RegistrarOnibusView extends StatefulWidget {
  const RegistrarOnibusView({super.key});

  @override
  State<RegistrarOnibusView> createState() => _RegistrarOnibusViewState();
}

class _RegistrarOnibusViewState extends State<RegistrarOnibusView> {
  late final TextEditingController _nomeMotorista;
  late final TextEditingController _modeloOnibus;
  late final TextEditingController _placa;
  late final TextEditingController _destino;
  late final TextEditingController _numeroVagas;

  var nomesError = false;
  var modeloError = false;
  var placaErro = false;
  var destinoError = false;
  var vagasError = false;

  @override
  void initState() {
    _nomeMotorista = TextEditingController();
    _modeloOnibus = TextEditingController();
    _placa = TextEditingController();
    _destino = TextEditingController();
    _numeroVagas = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _nomeMotorista.dispose();
    _modeloOnibus.dispose();
    _placa.dispose();
    _destino.dispose();
    _numeroVagas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maskFormatterPlaca = MaskTextInputFormatter(
        mask: '###-####', filter: {"#": RegExp(r'[0-9A-Za-z]')});
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          backgroundColor: scaffoldColor,
          appBar: appBar("Registrar Ônibus"),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: <Widget>[
                SizedBox(
                  child: Column(children: [
                    motoristaTextField(),
                    modeloTextField(),
                    placaTextField(maskFormatterPlaca),
                    destinoTextField(),
                    vagasTextField(),
                  ]),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: addButton(context, maskFormatterPlaca)),
              ],
            ),
          )),
    );
  }

  Padding addButton(BuildContext context, maskFormatterPlaca) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: ElevatedButton(
          style: styleButton(),
          onPressed: () async {
            FocusScope.of(context).unfocus();
            bool isConnected = await checkInternetConnection();
            if (isConnected) {
              final nome = _nomeMotorista.text;
              final modelo = _modeloOnibus.text;
              final placa = maskFormatterPlaca.unmaskText(_placa.text);
              final destino = _destino.text;
              final numeroVagas = _numeroVagas.text;

              validarRegistros(nome, modelo, placa, destino, numeroVagas);

              if (checarErros()) {
                final prefeitura = await getUser();

                final docRef = await FirebaseFirestore.instance
                    .collection("prefeituras/${prefeitura.id}/onibus/")
                    .add({
                  'motorista': nome,
                  'modelo': modelo,
                  'placa': placa,
                  'destino': destino,
                  'idPrefeitura': prefeitura.id,
                  'id': '',
                  'numeroVagas': numeroVagas,
                  'vagasRestantes': numeroVagas,
                  'profilePic': '',
                });

                final idCurrent = docRef.id.toString();

                final usera = FirebaseFirestore.instance
                    .collection("prefeituras/${prefeitura.id}/onibus/")
                    .doc(idCurrent);

                usera.update({'id': idCurrent});

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green,
                  content: Text("Adicionado"),
                ));

                final snapshotBus = await FirebaseFirestore.instance
                    .collection("prefeituras/${prefeitura.id}/onibus/")
                    .get();

                List listaBus = [];

                for (var doc in snapshotBus.docs) {
                  listaBus.add(doc.data());
                }

                saveListModels('listaOnibus', listaBus);

                Navigator.pop(context);
              }
            } else {
              showErrorMessage(context, "Não há conexão com a internet");
            }
          },
          child: const Text("Adicionar")),
    );
  }

  bool checarErros() {
    if (!nomesError &&
        !modeloError &&
        !placaErro &&
        !destinoError &&
        !vagasError) {
      return true;
    } else {
      return false;
    }
  }

  void validarRegistros(
      String nome, String modelo, String placa, String destino, String vagas) {
    nome = nome.trim();
    modelo = modelo.trim();
    List<String> listaNome = nome.split(' ');
    List<String> listaModelo = modelo.split(' ');
    print(placa.length);
    setState(() {
      if (listaNome.isEmpty || listaNome[0] == '') {
        nomesError = true;
      }
      if (listaModelo.isEmpty || listaModelo[0] == '') {
        modeloError = true;
      }
      if (placa.length < 7) {
        placaErro = true;
      }

      if (destino.isEmpty) {
        destinoError = true;
      }
      if (vagas.isEmpty) {
        vagasError = true;
      }
      //
    });
  }

  Padding vagasTextField() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _numeroVagas,
        keyboardType: TextInputType.number,
        decoration: estiloTextField("Numero de vagas",
            erro: vagasError, msg: "Digite o numero de vagas"),
        onChanged: (value) {
          if (vagasError) {
            setState(() {
              vagasError = false;
            });
          }
        },
      ),
    );
  }

  Padding destinoTextField() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _destino,
        decoration: estiloTextField("Destino",
            erro: destinoError, msg: "Digite o destino"),
        onChanged: (value) {
          if (destinoError) {
            setState(() {
              destinoError = false;
            });
          }
        },
      ),
    );
  }

  Padding placaTextField(maskFormatterPlaca) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        inputFormatters: [maskFormatterPlaca],
        controller: _placa,
        decoration: estiloTextField("Placa do Onibus",
            erro: placaErro, msg: "Digite uma placa valida"),
        onChanged: (value) {
          if (placaErro) {
            setState(() {
              placaErro = false;
            });
          }
        },
      ),
    );
  }

  Padding modeloTextField() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _modeloOnibus,
        keyboardType: TextInputType.number,
        decoration: estiloTextField("Modelo do Onibus",
            erro: modeloError, msg: "Digite o modelo do ônibus"),
        onChanged: (value) {
          if (modeloError) {
            setState(() {
              modeloError = false;
            });
          }
        },
      ),
    );
  }

  Padding motoristaTextField() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _nomeMotorista,
        decoration: estiloTextField("Nome do Motorista",
            erro: nomesError, msg: "Digite pelo menos o Nome e Sobrenome"),
        onChanged: (value) {
          if (nomesError) {
            setState(() {
              nomesError = false;
            });
          }
        },
      ),
    );
  }
}
