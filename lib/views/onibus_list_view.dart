import 'package:flutter/material.dart';
import 'package:pi/utils/dados_users.dart';
import 'package:pi/utils/show_error_message.dart';
import 'package:pi/utils/validador_login.dart';
import 'package:pi/views/onibus_view.dart';

import 'package:pi/views/registrar_bus.dart';

class OnibusView extends StatefulWidget {
  const OnibusView({super.key});

  @override
  State<OnibusView> createState() => _OnibusViewState();
}

class _OnibusViewState extends State<OnibusView> {
  List listaBus = [];
  bool isConnected = false;
  @override
  void initState() {
    super.initState();
    loadBusData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Column(
        children: [
          listaOnibus(context),
          addButton(context),
        ],
      ),
    );
  }

  ElevatedButton addButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        bool isConnected = await checkInternetConnection();

        if (isConnected) {
          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) => const RegistrarOnibusView()))
              .then((value) {
            loadBusData();
          });
        } else {
          await showErrorMessage(context, 'Internet Missing');
        }
      },
      child: const Text('Adicionar Onibus'),
    );
  }

  SizedBox listaOnibus(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 230,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: listaBus.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                builder: (context) => const InfoBusView(),
                settings: RouteSettings(
                  arguments: listaBus[index], // pass your data here
                ),
              ))
                  .then((value) {
                loadBusData();
              });
            },
            child: Container(
              width: 5000,
              height: 100,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.black)),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 60,
                    backgroundImage: AssetImage('assets/images/avatar.jpg'),
                  ),
                  Text(
                      "${listaBus[index].motorista}\n${listaBus[index].destino}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  loadBusData() async {
    final mapList = await getListOnibus();
    final connected = await checkInternetConnection();
    //mapList.removeWhere((mapa) => mapa.length == 0);

    setState(() {
      listaBus = mapList;
      isConnected = connected;
    });
  }
}

AppBar appBar() {
  return AppBar(
    title: const Text(
      "Lista de Onibus",
      style: TextStyle(color: Colors.black),
    ),
    backgroundColor: Colors.white,
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.black),
  );
}
