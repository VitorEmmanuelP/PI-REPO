import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:pi/utils/styles.dart';

import 'package:pi/views/add_aluno_onibus_view.dart';

import '../utils/check_internet.dart';
import '../utils/dados_users.dart';
import '../utils/show_error_message.dart';
import '../widgets/app_bar.dart';
import '../widgets/profile_pic.dart';

class InfoBusView extends StatefulWidget {
  const InfoBusView({super.key});

  @override
  State<InfoBusView> createState() => _InfoBusViewState();
}

class _InfoBusViewState extends State<InfoBusView> {
  Map<String, dynamic>? dados;
  int n = 0;
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      dados = args;
      print(dados);
    }
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: appBar("Informação Ônibus"),
      body: SingleChildScrollView(
        child: Center(
            child: Column(
          children: <Widget>[
            SizedBox(
              height: 190,
              width: 190,
              child: ProfilePictureWidget(
                info: dados,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(
                            children: [
                              const Text("Nome",
                                  style: TextStyle(color: Colors.blue)),
                              Text(dados!['motorista'],
                                  style: const TextStyle(
                                      color: Color.fromARGB(100, 69, 69, 69))),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const Text("Destino",
                                  style: TextStyle(color: Colors.blue)),
                              Text(dados!['destino'],
                                  style: const TextStyle(
                                      color: Color.fromARGB(100, 69, 69, 69))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(
                            children: [
                              const Text("Placa",
                                  style: TextStyle(color: Colors.blue)),
                              Text(dados!['placa'],
                                  style: const TextStyle(
                                      color: Color.fromARGB(100, 69, 69, 69))),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const Text("N. de Vagas",
                                  style: TextStyle(color: Colors.blue)),
                              Text(dados!['numeroVagas'],
                                  style: const TextStyle(
                                      color: Color.fromARGB(100, 69, 69, 69))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            listaDeAlunosDoOnibus(context),
            Container(
              color: Colors.blue,
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [addButton(context), deletarButton(context)],
              ),
            ),
          ],
        )),
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
                  builder: (context) => const AddALunoONibusView(),
                  settings: RouteSettings(
                    arguments: dados, // pass your data here
                  ),
                ))
                .then((value) {});
          } else {
            await showErrorMessage(context, "Não há conexão com a internet");
          }
        },
        child: const Text("Adicionar aluno ao onibusr"));
  }

  SizedBox listaDeAlunosDoOnibus(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 250,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("prefeituras/${dados!['idPrefeitura']}/users")
            .where('idOnibus', isEqualTo: dados!['id'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 70,
              child: Center(child: CircularProgressIndicator()),
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

            return sortedDocs.isNotEmpty
                ? Column(
                    children: [
                      Text(
                        "Vagas restantes: ${(int.parse(dados!['numeroVagas']) - sortedDocs.length).toString()}",
                      ),
                      Expanded(
                        child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: sortedDocs.length,
                            itemBuilder: (context, index) {
                              var data = sortedDocs[index].data()
                                  as Map<String, dynamic>;

                              if (data.isEmpty) {
                                return Container(
                                  color: Colors.amber,
                                );
                              }
                              var nome = sortedDocs[index]['nome'].split(' ');

                              return Column(children: [
                                Container(
                                  width: 5000,
                                  height: 120,
                                  margin: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 2),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: data['profilePic'] != ''
                                              ? CachedNetworkImage(
                                                  imageUrl: data['profilePic'],
                                                  placeholder: (context, url) =>
                                                      const CircularProgressIndicator(),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          CircleAvatar(
                                                    backgroundColor:
                                                        Colors.blue,
                                                    radius: 70,
                                                    child: Center(
                                                      child: Text(
                                                          '${nome[0][0]}${nome[1][0]}'),
                                                    ),
                                                  ),
                                                  imageBuilder: (context,
                                                          imageProvider) =>
                                                      CircleAvatar(
                                                    backgroundColor: Colors.red,
                                                    radius: 60,
                                                    backgroundImage:
                                                        imageProvider,
                                                  ),
                                                )
                                              : CircleAvatar(
                                                  backgroundColor: Colors.blue,
                                                  radius: 70,
                                                  child: Center(
                                                    child: Text(
                                                        '${nome[0][0].toUpperCase()}${nome[1][0].toUpperCase()}'),
                                                  ),
                                                ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: Text('${data['nome']}'),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                          onPressed: () {
                                            final id = data['id'];

                                            removerAlunoBus(id);
                                          },
                                          icon: const Icon(
                                            Icons.highlight_remove,
                                            size: 30,
                                          ))
                                    ],
                                  ),
                                )
                              ]);
                            }),
                      ),
                    ],
                  )
                : const Center(
                    child:
                        Text("Nao existe nenhum aluno cadrastado no onibus "));
          }
        },
      ),
    );
  }

  removerAlunoBus(id) async {
    final usera = FirebaseFirestore.instance
        .collection("prefeituras/${dados!['idPrefeitura']}/users/")
        .doc(id);

    usera.update({'idOnibus': ''});

    await atualizarVagas();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      duration: Duration(milliseconds: 500),
      behavior: SnackBarBehavior.fixed,
      backgroundColor: Colors.red,
      content: Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Center(
            child: Text(
          "Usuario Removido",
        )),
      ),
    ));
  }

  Future<void> atualizarVagas() async {
    final vagas = FirebaseFirestore.instance
        .collection("prefeituras/${dados!['idPrefeitura']}/onibus/")
        .doc(dados!["id"]);

    final infos = await vagas.get().then((value) => value.data() as Map);

    final numeroDeVagas = int.parse(infos['vagasRestantes']);

    await vagas.update({"vagasRestantes": (numeroDeVagas + 1).toString()});
  }

  ElevatedButton deletarButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          final bool shouldDelete = await showDeleteDialog(
              context, "Deletar Ônibus", "Deseja deletar o ônibus?");
          bool isConnected = await checkInternetConnection();
          if (shouldDelete) {
            if (isConnected) {
              final user = FirebaseFirestore.instance
                  .collection('prefeituras/${dados!['idPrefeitura']}/onibus/')
                  .doc(dados!['id']);

              user.delete();

              atualizarStored();
              removerDadosAlunos();
              Navigator.of(context).pop();
            } else {
              await showErrorMessage(context, 'Não há conexão com a internet');
            }
          }
        },
        child: const Text('Deletar'));
  }

  removerDadosAlunos() async {
    final user = await FirebaseFirestore.instance
        .collection('prefeituras/${dados!['idPrefeitura']}/users/')
        .where('idOnibus', isEqualTo: dados!['id'])
        .get();

    for (var aluno in user.docs) {
      aluno.reference.update({'idOnibus': ''});
    }
  }

  atualizarStored() async {
    final List listaOnibus = await getListOnibus();

    listaOnibus.removeWhere((mapa) => mapa.id == dados!['id']);

    saveListModels('listaOnibus', listaOnibus);
  }
}
