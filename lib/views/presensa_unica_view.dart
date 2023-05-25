import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pi/models/user_data.dart';

class PresencaUnicaView extends StatefulWidget {
  const PresencaUnicaView({super.key});

  @override
  State<PresencaUnicaView> createState() => _PresencaUnicaViewState();
}

class _PresencaUnicaViewState extends State<PresencaUnicaView> {
  Map<String, dynamic>? data;
  UserData? dados;

  @override
  Widget build(BuildContext context) {
    final List? args = ModalRoute.of(context)?.settings.arguments as List?;
    if (args != null) {
      dados = args[0];
      data = args[1];
    }
    return Scaffold(
      appBar: appBar(),
      body: listazada(context),
    );
  }

  SizedBox listazada(BuildContext context) {
    return SizedBox(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(
                'prefeituras/${dados!.idPrefeitura}/onibus/${dados!.idOnibus}/listaPresensa/${data!['nome']}/alunos')
            .snapshots()
            .asyncMap((querySnapshot1) async {
          var querySnapshot2 = await FirebaseFirestore.instance
              .collection('prefeituras/${dados!.idPrefeitura}/users/')
              .where('idOnibus', isEqualTo: dados!.idOnibus)
              .get();
          return [querySnapshot1, querySnapshot2];
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.data != null) {
              final snapshot1 = snapshot.data![0];
              final snapshot2 = snapshot.data![1];

              List<QueryDocumentSnapshot> sortedDocs1 =
                  List<QueryDocumentSnapshot>.from(snapshot1.docs);

              int? inde;

              sortedDocs1.removeWhere((element) {
                var info = element.data() as Map;
                if (info['nome'] == dados!.nome) {
                  inde = sortedDocs1.indexOf(element);
                  return true;
                }
                return false;
              });

              sortedDocs1.sort((a, b) {
                var nomeA = a.data() as Map;
                var nomeB = b.data() as Map;

                String aa = nomeA['nome'];
                String bb = nomeB['nome'];

                aa = aa.toString().toUpperCase();
                bb = bb.toString().toUpperCase();

                return aa.compareTo(bb);
              });

              try {
                sortedDocs1.insert(0, snapshot1.docs[inde!]);
                final mapzada = {};

                for (var i in snapshot2.docs) {
                  final dados = i.data() as Map;
                  mapzada[dados['id']] = dados['profilePic'];
                }

                return listaPresensa(sortedDocs1, mapzada);
              } finally {
                final mapzada = {};

                for (var i in snapshot2.docs) {
                  final dados = i.data();
                  mapzada[dados['id']] = dados['profilePic'];
                }

                return listaPresensa(sortedDocs1, mapzada);
              }
            } else {
              return Container();
            }
          }
        },
      ),
    );
  }

  ListView listaPresensa(
      List<QueryDocumentSnapshot<Object?>> sortedDocs, Map mapzada) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: sortedDocs.length,
      itemBuilder: (context, index) {
        var data = sortedDocs[index].data() as Map<String, dynamic>;

        final nome = data['nome'].toUpperCase().split(' ');

        return Column(
          children: [
            Container(
              width: 5000,
              height: 100,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                    width: 2,
                    color: data['status'] == 'ausente'
                        ? Colors.red
                        : Colors.green),
              ),
              child: Row(children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: mapzada.containsKey(data['id']) &&
                          mapzada['${data['id']}'] != ''
                      ? CachedNetworkImage(
                          imageUrl: mapzada[data['id']],
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => CircleAvatar(
                            radius: 60,
                            child: Center(
                              child: Text(
                                "${nome[0][0]}${nome[1][0]}",
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
                          radius: 60,
                          child: Center(
                            child: Text(
                              "${nome[0][0].toUpperCase()}${nome[1][0].toUpperCase()}",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 35),
                            ),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text('${data['nome']}\n${data['status']}'),
                ),
                const Spacer(),
              ]),
            ),
          ],
        );
      },
    );
  }

  AppBar appBar() {
    return AppBar(
      title: Text(
        "Presenca do dia ${data!['nome']}",
        style: const TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }
}