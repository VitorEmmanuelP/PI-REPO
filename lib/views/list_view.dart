import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ListaAlunoView extends StatefulWidget {
  const ListaAlunoView({super.key});

  @override
  State<ListaAlunoView> createState() => _ListaAlunoViewState();
}

class _ListaAlunoViewState extends State<ListaAlunoView> {
  List listaDeAlunos = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadLista();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de alunos"),
      ),
      body: ListView.builder(
          itemCount: listaDeAlunos.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Container(
                  width: 5000,
                  height: 100,
                  margin: const EdgeInsets.all(20),
                  color: Colors.blue,
                  child: Row(children: [
                    const CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 70,
                      backgroundImage: NetworkImage(
                          'https://png.pngtree.com/png-vector/20191101/ourmid/pngtree-cartoon-color-simple-male-avatar-png-image_1934459.jpg'),
                    ),
                    Text(listaDeAlunos[index]['nome'])
                  ]),
                )
              ],
            );
          }),
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
}
