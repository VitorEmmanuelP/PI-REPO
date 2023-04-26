import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/dados_users.dart';

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

  var nomesError = false;
  var placaErro = false;
  var dataError = false;

  @override
  void initState() {
    _nomeMotorista = TextEditingController();
    _modeloOnibus = TextEditingController();
    _placa = TextEditingController();
    _destino = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _nomeMotorista.dispose();
    _modeloOnibus.dispose();
    _placa.dispose();
    _destino.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: appBar(),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: _nomeMotorista,
                    decoration: estiloTextField("Nome do Motorista",
                        erro: nomesError,
                        msg: "Digite pelo menos o Nome e Sobrenome"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                      controller: _modeloOnibus,
                      keyboardType: TextInputType.number,
                      decoration: estiloTextField("Modelo do Onibus")),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: _placa,
                    decoration: estiloTextField("Placa do Onibus"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: _destino,
                    decoration: estiloTextField("Destino"),
                  ),
                ),
                OutlinedButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      final nome = _nomeMotorista.text;
                      final modelo = _modeloOnibus.text;
                      final placa = _placa.text;
                      final destino = _destino.text;

                      final dadosString = await getInfoUser();

                      final docRef = await FirebaseFirestore.instance
                          .collection(
                              "prefeituras/${dadosString['id']}/onibus/")
                          .add({
                        'motorista': nome,
                        'modelo': modelo,
                        'placa': placa,
                        'destino': destino,
                        'idPrefeitura': dadosString['id'],
                        'id': '',
                      });

                      final idCurrent = docRef.id.toString();

                      final usera = FirebaseFirestore.instance
                          .collection(
                              "prefeituras/${dadosString['id']}/onibus/")
                          .doc(idCurrent);

                      usera.update({'id': idCurrent});

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green,
                        content: Text("Adicionado"),
                      ));

                      final snapshotBus = await FirebaseFirestore.instance
                          .collection(
                              "prefeituras/${dadosString['id']}/onibus/")
                          .get();

                      List listaBus = [];

                      for (var doc in snapshotBus.docs) {
                        listaBus.add(doc.data());
                      }

                      setListShared('listaOnibus', listaBus);

                      Navigator.pop(context);
                    },
                    child: const Text("Adicionar"))
              ],
            ),
          )),
    );
  }
}

InputDecoration estiloTextField(String label,
    {bool erro = false, String msg = ''}) {
  return InputDecoration(
    labelText: label,
    errorText: erro ? msg : null,
    labelStyle:
        const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    enabledBorder: fazerBorda(),
    focusedBorder: fazerBorda(),
    errorBorder: fazerBorda(erro: erro),
    focusedErrorBorder: fazerBorda(erro: erro),
  );
}

OutlineInputBorder fazerBorda({bool erro = false}) {
  return OutlineInputBorder(
    borderSide: BorderSide(color: erro ? Colors.red : Colors.black),
    borderRadius: BorderRadius.circular(10),
  );
}

AppBar appBar() {
  return AppBar(
    title: const Text(
      "Registrar Onibus",
      style: TextStyle(color: Colors.black),
    ),
    backgroundColor: Colors.white,
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.black),
  );
}
