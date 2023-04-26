import 'package:flutter/material.dart';
import 'package:pi/utils/dados_users.dart';
import 'package:pi/views/info_bus_view.dart';

import 'package:pi/views/registrar_bus.dart';

import '../constants/routes.dart';

class OnibusView extends StatefulWidget {
  const OnibusView({super.key});

  @override
  State<OnibusView> createState() => _OnibusViewState();
}

class _OnibusViewState extends State<OnibusView> {
  List listaBus = [];
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
          listaBus.isEmpty ? const Text("Sem Onibus") : listaOnibus(context),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => const RegistrarOnibusView()))
                  .then((value) {
                loadBusData();
              });
            },
            child: const Text('Adicionar Onibus'),
          ),
        ],
      ),
    );
  }

  Container listaOnibus(BuildContext context) {
    return Container(
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
              child: Row(children: [
                const CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 60,
                  backgroundImage: NetworkImage(
                      'https://png.pngtree.com/png-vector/20191101/ourmid/pngtree-cartoon-color-simple-male-avatar-png-image_1934459.jpg'),
                ),
                Text(
                    "${listaBus[index]['motorista']}\n${listaBus[index]['destino']}"),
              ]),
            ),
          );
        },
      ),
    );
  }

  loadBusData() async {
    final mapList = await getListShared('listaOnibus');

    mapList.removeWhere((mapa) => mapa.length == 0);

    setState(() {
      listaBus = mapList;
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
