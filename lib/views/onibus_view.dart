import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import 'package:pi/views/add_aluno_onibus_view.dart';

import '../utils/check_internet.dart';
import '../utils/dados_users.dart';
import '../utils/show_error_message.dart';
import '../widgets/profile_pic.dart';

class InfoBusView extends StatefulWidget {
  const InfoBusView({super.key});

  @override
  State<InfoBusView> createState() => _InfoBusViewState();
}

class _InfoBusViewState extends State<InfoBusView> {
  Map<String, dynamic>? dados;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      dados = args;
    }
    return Scaffold(
      appBar: appBar(),
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
            Container(
                width: double.infinity,
                height: 700,
                color: Colors.red,
                child: Center(child: Text(dados!['motorista']))),
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
            await showErrorMessage(context, "Not internet");
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
                ? ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: sortedDocs.length,
                    itemBuilder: (context, index) {
                      var data =
                          sortedDocs[index].data() as Map<String, dynamic>;

                      if (data.isEmpty) {
                        return Container(
                          color: Colors.amber,
                        );
                      }
                      var nome = sortedDocs[index]['nome'].split(' ');

                      return Column(children: [
                        Container(
                          width: 5000,
                          height: 100,
                          margin: const EdgeInsets.all(20),
                          decoration:
                              BoxDecoration(border: Border.all(width: 2)),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 100,
                                width: 100,
                                child: data['profilePic'] != ''
                                    ? CachedNetworkImage(
                                        imageUrl: data['profilePic'],
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            CircleAvatar(
                                          backgroundColor: Colors.blue,
                                          radius: 70,
                                          child: Center(
                                            child: Text(
                                                '${nome[0][0]}${nome[1][0]}'),
                                          ),
                                        ),
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                CircleAvatar(
                                          backgroundColor: Colors.red,
                                          radius: 60,
                                          backgroundImage: imageProvider,
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
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
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
                    })
                : const Center(
                    child:
                        Text("Nao existe nenhum aluno cadrastado no onibus "));
          }
        },
      ),
    );
  }

  removerAlunoBus(id) {
    final usera = FirebaseFirestore.instance
        .collection("prefeituras/${dados!['idPrefeitura']}/users/")
        .doc(id);

    usera.update({'idOnibus': ''});

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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

  ElevatedButton deletarButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          final bool shouldDelete = await showDeleteDialog(context);
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
              await showErrorMessage(context, 'Internet Missing');
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

  AppBar appBar() {
    return AppBar(
      title: const Text(
        "Infomação do onibus",
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }
}
