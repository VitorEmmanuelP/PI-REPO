import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pi/constants/routes.dart';
import 'package:pi/utils/dados_users.dart';
import 'package:pi/utils/show_error_message.dart';
import 'package:pi/utils/validador_login.dart';

import '../models/bus_data.dart';
import '../models/prefeitura_data.dart';

class OnibusView extends StatefulWidget {
  const OnibusView({super.key});

  @override
  State<OnibusView> createState() => _OnibusViewState();
}

class _OnibusViewState extends State<OnibusView> {
  List<BusData> listaBus = [];
  bool isConnected = false;
  PrefeituraData? dados;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Column(
        children: [
          listaOnibus(context),
          //addButton(context),
        ],
      ),
    );
  }

  ElevatedButton addButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        bool isConnected = await checkInternetConnection();

        if (isConnected) {
          Navigator.of(context).pushNamed(registerBusRoute);
        } else {
          await showErrorMessage(context, 'Internet Missing');
        }
      },
      child: const Text('Adicionar Onibus'),
    );
  }

  SizedBox listaOnibus(BuildContext context) {
    final PrefeituraData? args =
        ModalRoute.of(context)?.settings.arguments as PrefeituraData?;

    if (args != null) {
      dados = args;
    }
    return SizedBox(
        height: MediaQuery.of(context).size.height - 230,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('prefeituras/${dados!.id}/onibus')
              .where("id", isNotEqualTo: '')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              final snapshotBus = snapshot.data!.docs;

              for (var info in snapshotBus) {
                var infoBus = info.data() as Map;

                final onibus = BusData(
                    motorista: infoBus['motorista'],
                    id: infoBus['id'],
                    destino: infoBus['destino'],
                    idPrefeitura: infoBus['idPrefeitura'],
                    modelo: infoBus['modelo'],
                    placa: infoBus['placa'],
                    numero_vagas: infoBus['numero_vagas']);

                listaBus.add(onibus);
              }

              return listView(context, listaBus);
            }
          },
        ));
  }

  SizedBox listView(BuildContext context, List<BusData> listaBus) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 230,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: listaBus.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              Navigator.of(context)
                  .pushNamed(infoBusRoute, arguments: listaBus[index]);
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
                      "${listaBus[index].motorista}\n${listaBus[index].destino} ${listaBus[index].motorista} ${listaBus[index].numero_vagas}"),
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
