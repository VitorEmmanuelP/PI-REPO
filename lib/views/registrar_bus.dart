import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  var placaErro = false;
  var dataError = false;

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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          backgroundColor: scaffoldColor,
          appBar: appBar("Registrar Ônibus"),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: <Widget>[
                motoristaTextField(),
                modeloTextField(),
                placaTextField(),
                destinoTextField(),
                vagasTextField(),
                addButton(context)
              ],
            ),
          )),
    );
  }

  OutlinedButton addButton(BuildContext context) {
    return OutlinedButton(
        onPressed: () async {
          FocusScope.of(context).unfocus();
          bool isConnected = await checkInternetConnection();
          if (isConnected) {
            final nome = _nomeMotorista.text;
            final modelo = _modeloOnibus.text;
            final placa = _placa.text;
            final destino = _destino.text;
            final numeroVagas = _numeroVagas.text;

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
          } else {
            showErrorMessage(context, "Missing Internet");
          }
        },
        child: const Text("Adicionar"));
  }

  Padding vagasTextField() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _numeroVagas,
        decoration: estiloTextField("Numero de vagas"),
      ),
    );
  }

  Padding destinoTextField() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _destino,
        decoration: estiloTextField("Destino"),
      ),
    );
  }

  Padding placaTextField() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _placa,
        decoration: estiloTextField("Placa do Onibus"),
      ),
    );
  }

  Padding modeloTextField() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
          controller: _modeloOnibus,
          keyboardType: TextInputType.number,
          decoration: estiloTextField("Modelo do Onibus")),
    );
  }

  Padding motoristaTextField() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _nomeMotorista,
        decoration: estiloTextField("Nome do Motorista",
            erro: nomesError, msg: "Digite pelo menos o Nome e Sobrenome"),
      ),
    );
  }
}
