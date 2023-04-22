import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pi/constants/routes.dart';
import 'package:pi/views/register_view.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ListaAlunoView extends StatefulWidget {
  const ListaAlunoView({super.key});

  @override
  State<ListaAlunoView> createState() => _ListaAlunoViewState();
}

class _ListaAlunoViewState extends State<ListaAlunoView> {
  List listaDeAlunos = [];

  @override
  Widget build(BuildContext context) {
    final List<dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as List<dynamic>?;

    if (args != null) {
      listaDeAlunos = args;
    }

    return Scaffold(
      appBar: appBar(),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height - 230,
            child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: listaDeAlunos.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async => await Navigator.of(context)
                        .pushNamed(userRoute, arguments: listaDeAlunos[index]),
                    child: Column(
                      children: [
                        Container(
                          width: 5000,
                          height: 100,
                          margin: const EdgeInsets.all(20),
                          decoration:
                              BoxDecoration(border: Border.all(width: 2)),
                          child: Row(children: [
                            const CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 60,
                              backgroundImage: NetworkImage(
                                  'https://png.pngtree.com/png-vector/20191101/ourmid/pngtree-cartoon-color-simple-male-avatar-png-image_1934459.jpg'),
                            ),
                            Text(
                                '${listaDeAlunos[index]['nome']}\n ${listaDeAlunos[index]['status']}')
                          ]),
                        )
                      ],
                    ),
                  );
                }),
          ),
          OutlinedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                  builder: (context) => RegistrarAlunoView(),
                ))
                    .then((value) {
                  loadLista();
                });
              },
              child: const Text('Adicionar Alunos'))
        ],
      ),
    );
  }

  loadLista() async {
    SharedPreferences shared = await SharedPreferences.getInstance();

    final a = shared.getStringList('listaAlunos');
    if (a != null) {
      final mapList = a.map((string) {
        return json.decode(string);
      }).toList();
      setState(() {
        listaDeAlunos = mapList;
      });
    }
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        "Lista de Alunos",
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }
}
