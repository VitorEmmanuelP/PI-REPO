import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pi/constants/routes.dart';
import 'package:pi/utils/dados_users.dart';
import 'package:pi/utils/show_error_message.dart';
import 'package:pi/utils/styles.dart';
import 'package:pi/utils/validador_login.dart';

import '../models/bus_data.dart';
import '../models/prefeitura_data.dart';
import '../widgets/app_bar.dart';

class OnibusView extends StatefulWidget {
  const OnibusView({super.key});

  @override
  State<OnibusView> createState() => _OnibusViewState();
}

class _OnibusViewState extends State<OnibusView> {
  List<BusData> listaBus = [];
  bool isConnected = false;
  PrefeituraData? dados;
  List<String> nome = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: appBar("Lista dos Ônibus"),
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

              return listView(context, snapshotBus);
            }
          },
        ));
  }

  SizedBox listView(
      BuildContext context, List<QueryDocumentSnapshot> listaBus) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 230,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: listaBus.length,
        itemBuilder: (context, index) {
          final data = listaBus[index].data() as Map;
          nome = data['motorista'].trim().split(' ');

          return GestureDetector(
            onTap: () async {
              Navigator.of(context).pushNamed(infoBusRoute, arguments: data);
            },
            child: Container(
              width: 5000,
              height: 100,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.black)),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: data['profilePic'] != ''
                        ? CachedNetworkImage(
                            imageUrl: data['profilePic'],
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => CircleAvatar(
                              backgroundColor: Colors.blue,
                              radius: 70,
                              child: Center(
                                child: Text(
                                  "${nome[0][0].toUpperCase()}${nome[1][0].toUpperCase()}",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 35),
                                ),
                              ),
                            ),
                            imageBuilder: (context, imageProvider) =>
                                CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 60,
                              backgroundImage: imageProvider,
                            ),
                          )
                        : CircleAvatar(
                            radius: 70,
                            child: Center(
                                child: Text(
                              nome.length == 1
                                  ? nome[0][0].toUpperCase()
                                  : "${nome[0][0].toUpperCase()}${nome[1][0].toUpperCase()}",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 35),
                            )),
                          ),
                  ),
                  Text(
                      "${data['motorista']}\n${data['destino']}  ${data['numeroVagas']}"),
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
