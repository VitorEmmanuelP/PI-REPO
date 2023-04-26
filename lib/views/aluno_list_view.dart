import 'package:flutter/material.dart';

import 'package:pi/utils/dados_users.dart';
import 'package:pi/views/register_aluno_view.dart';
import 'package:pi/views/user_view.dart';

class ListaAlunoView extends StatefulWidget {
  const ListaAlunoView({super.key});

  @override
  State<ListaAlunoView> createState() => _ListaAlunoViewState();
}

class _ListaAlunoViewState extends State<ListaAlunoView> {
  List listaDeAlunos = [];
  List<String> nome = [];
  @override
  void initState() {
    loadLista();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Column(
        children: [
          listaDeAlunos.isEmpty
              ? const Text("Sem alunos")
              : listaAluno(context),
          addAluno(context)
        ],
      ),
    );
  }

  OutlinedButton addAluno(BuildContext context) {
    return OutlinedButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(
            builder: (context) => const RegistrarAlunoView(),
          ))
              .then((value) {
            loadLista();
          });
        },
        child: const Text('Adicionar Alunos'));
  }

  Container listaAluno(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 230,
      child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: listaDeAlunos.length,
          itemBuilder: (context, index) {
            nome = listaDeAlunos[index]['nome'].split(' ');

            return GestureDetector(
              onTap: () async {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                  builder: (context) => const UserView(),
                  settings: RouteSettings(
                    arguments: listaDeAlunos[index], // pass your data here
                  ),
                ))
                    .then((value) {
                  loadLista();
                });
              },
              child: Column(
                children: [
                  Container(
                    width: 5000,
                    height: 100,
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(border: Border.all(width: 2)),
                    child: Row(children: [
                      listaDeAlunos[index]['profilePic'] != ''
                          ? CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 60,
                              backgroundImage: NetworkImage(
                                  listaDeAlunos[index]['profilePic']),
                            )
                          : CircleAvatar(
                              radius: 70,
                              child: Center(
                                child: Text(
                                  "${nome.isNotEmpty ? nome[0][0] : ''}${nome.isNotEmpty && nome.length > 1 ? nome[1][0] : ''}",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 35),
                                ),
                              ),
                            ),
                      Text(
                          '${listaDeAlunos[index]['nome']}\n ${listaDeAlunos[index]['status']}')
                    ]),
                  )
                ],
              ),
            );
          }),
    );
  }

  loadLista() async {
    final mapList = await getListShared('listaAlunos');
    mapList.removeWhere((mapa) => mapa.length == 0);

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
