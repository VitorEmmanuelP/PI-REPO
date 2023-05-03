import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:pi/utils/dados_users.dart';
import 'package:pi/utils/validador_login.dart';
import 'package:pi/views/register_aluno_view.dart';
import 'package:pi/views/user_view.dart';

import '../utils/show_error_message.dart';

class ListaAlunoView extends StatefulWidget {
  const ListaAlunoView({super.key});

  @override
  State<ListaAlunoView> createState() => _ListaAlunoViewState();
}

class _ListaAlunoViewState extends State<ListaAlunoView> {
  String name = '';
  Map? dados;
  List listaDeAlunos = [];
  List<String> nome = [];
  bool isConnected = false;

  @override
  void initState() {
    loadLista();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [searchBar(), listaAluno(context), addAluno(context)],
        ),
      ),
    );
  }

  SizedBox listaAluno(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      dados = args;
    }
    return SizedBox(
        height: MediaQuery.of(context).size.height - 230,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('prefeituras/${dados!['id']}/users')
              .where("nome", isNotEqualTo: '')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              List<QueryDocumentSnapshot> sortedDocs =
                  List<QueryDocumentSnapshot>.from(snapshot.data!.docs);
              sortedDocs.sort((a, b) {
                var nomeA = a.data() as Map;
                var nomeB = b.data() as Map;

                String aa = nomeA['nome'];
                String bb = nomeB['nome'];

                aa = aa.toString().toUpperCase();
                bb = bb.toString().toUpperCase();

                return aa.compareTo(bb);
              });

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: sortedDocs.length,
                itemBuilder: (context, index) {
                  //print(sortedDocs[0].data());
                  //sortedDocs.removeWhere((mapa) => mapa.data() == 0);

                  var data = sortedDocs[index].data() as Map<String, dynamic>;

                  nome = sortedDocs[index]['nome'].split(' ');

                  if (data.isEmpty) {
                    return Container(
                      color: Colors.amber,
                    );
                  }

                  if (name.isEmpty) {
                    return GestureDetector(
                      onTap: () async {
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                          builder: (context) => const UserView(),
                          settings: RouteSettings(
                            arguments: data, // pass your data here
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
                            decoration:
                                BoxDecoration(border: Border.all(width: 2)),
                            child: Row(children: [
                              data['profilePic'] != '' && isConnected
                                  ? CircleAvatar(
                                      backgroundColor: Colors.red,
                                      radius: 60,
                                      backgroundImage:
                                          NetworkImage(data['profilePic']),
                                    )
                                  : CircleAvatar(
                                      radius: 70,
                                      child: Center(
                                        child: Text(
                                          "${nome.isNotEmpty ? nome[0][0] : ''}${nome.isNotEmpty && nome.length > 1 ? nome[1][0] : ''}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 35),
                                        ),
                                      ),
                                    ),
                              Text('${data['nome']}\n ${data['status']}'),
                            ]),
                          ),
                        ],
                      ),
                    );
                  }
                  if (data['nome']
                      .toString()
                      .toLowerCase()
                      .startsWith(name.toLowerCase())) {
                    return GestureDetector(
                      onTap: () async {
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                          builder: (context) => const UserView(),
                          settings: RouteSettings(
                            arguments: data, // pass your data here
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
                            decoration:
                                BoxDecoration(border: Border.all(width: 2)),
                            child: Row(children: [
                              data['profilePic'] != '' && isConnected
                                  ? CircleAvatar(
                                      backgroundColor: Colors.red,
                                      radius: 60,
                                      backgroundImage:
                                          NetworkImage(data['profilePic']),
                                    )
                                  : CircleAvatar(
                                      radius: 70,
                                      child: Center(
                                        child: Text(
                                          "${nome.isNotEmpty ? nome[0][0] : ''}${nome.isNotEmpty && nome.length > 1 ? nome[1][0] : ''}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 35),
                                        ),
                                      ),
                                    ),
                              Text('${data['nome']}\n ${data['status']}'),
                            ]),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              );
            }
          },
        ));
  }

  Container searchBar() {
    return Container(
      width: MediaQuery.of(context).size.width - 35,
      child: TextField(
        onChanged: (value) {
          setState(() {
            name = value;
          });
        },
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(10)),
            prefixIcon: Icon(Icons.search),
            hintText: "Search.."),
      ),
    );
  }

  OutlinedButton addAluno(BuildContext context) {
    return OutlinedButton(
        onPressed: () async {
          bool isConnected = await checkInternetConnection();

          if (isConnected) {
            Navigator.of(context)
                .push(MaterialPageRoute(
              builder: (context) => const RegistrarAlunoView(),
            ))
                .then((value) {
              loadLista();
            });
          } else {
            await showErrorMessage(context, "Not internet");
          }
        },
        child: const Text('Adicionar Alunos'));
  }

  loadLista() async {
    final mapList = await getListShared('listaAlunos');
    mapList.removeWhere((mapa) => mapa.length == 0);
    bool connected = await checkInternetConnection();

    setState(() {
      listaDeAlunos = mapList;
      isConnected = connected;
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
