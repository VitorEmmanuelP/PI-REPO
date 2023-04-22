import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:pi/views/registrar_bus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/routes.dart';

class OnibusView extends StatefulWidget {
  const OnibusView({super.key});

  @override
  State<OnibusView> createState() => _OnibusViewState();
}

class _OnibusViewState extends State<OnibusView> {
  List listaBus = [];

  @override
  Widget build(BuildContext context) {
    final List<dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
    if (args != null) {
      listaBus = args;
    }

    return Scaffold(
      appBar: appBar(),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height - 230,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: listaBus.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async => await Navigator.of(context)
                      .pushNamed(infoBusRoute, arguments: listaBus[index]),
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
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => RegistrarOnibusView()))
                  .then((value) async {
                await loadBusData();
              });
            },
            child: Text('Adicionar Onibus'),
          ),
        ],
      ),
    );
  }

  loadBusData() async {
    SharedPreferences shared = await SharedPreferences.getInstance();

    final listaBuses = shared.getStringList('listaOnibus');

    if (listaBuses != null) {
      final mapList = listaBuses.map((string) {
        return json.decode(string);
      }).toList();

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
}
