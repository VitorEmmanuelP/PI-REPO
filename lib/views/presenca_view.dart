import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:pi/constants/routes.dart';
import 'package:pi/models/bus_data.dart';

import 'package:pi/models/user_data.dart';
import 'package:pi/utils/dados_users.dart';

import '../utils/enviar_mensagens.dart';

class PresencaView extends StatefulWidget {
  const PresencaView({Key? key}) : super(key: key);

  @override
  State<PresencaView> createState() => _PresencaViewState();
}

class _PresencaViewState extends State<PresencaView> {
  int _numberOfTabs = 0;
  UserData? dados;
  BusData? onibusInfo;
  List listaPresensaTodos = [];
  String formattedDate = '';
  String? infoQr;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
    DateTime now = DateTime.now();

    if (args != null) {
      dados = args[0];
      onibusInfo = args[1];
      formattedDate = DateFormat('dd-MM-yyyy').format(now);
    }

    return dados!.idOnibus != ''
        ? presensa()
        : const Scaffold(
            body: Center(child: Text('Nao esta cadastrado em nenhum onibus')),
          );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> presensa() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(
              '/prefeituras/${dados!.idPrefeitura}/onibus/${dados!.idOnibus}/listaPresensa')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar os dados'));
        }

        final tabsData = snapshot.data!.docs;

        var listaData = [];

        for (var i in tabsData) {
          listaData.add(i.data());
        }

        DateFormat format = DateFormat("dd-MM-yyyy");
        listaData.sort((a, b) =>
            format.parse(b['nome']).compareTo(format.parse(a['nome'])));

        if (listaData.length > 10) {
          listaData = listaData.sublist(0, 10);
          _numberOfTabs = listaData.length;
        } else {
          _numberOfTabs = snapshot.data!.docs.length;
        }

        return DefaultTabController(
          length: _numberOfTabs,
          child: Scaffold(
              appBar: appBar(listaData),
              body: _numberOfTabs != 0
                  ? tabsView(context, listaData)
                  : const Center(
                      child: Text("Nao existe lista de presensa"),
                    )),
        );
      },
    );
  }

  AppBar appBar(List<dynamic> listaData) {
    return AppBar(
      title: const Text('Lista de presensa',
          style: TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      actions: <Widget>[
        if (dados!.status == 'coordenador')
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(
                onPressed: () {
                  createLista();
                },
                icon: const Icon(Icons.add)),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 5),
          child: IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(presencaTodosRoute, arguments: dados);
              },
              icon: const Icon(Icons.list_alt)),
        ),
        if (dados!.status == 'coordenador')
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
                onPressed: () async {
                  await readQrCode();

                  var info = '=$infoQr';

                  info = info.split('').reversed.join();
                  info = utf8.decode(base64.decode(info));

                  if (infoQr != '-1') {
                    final ref = await FirebaseFirestore.instance
                        .collection(
                            'prefeituras/${dados!.idPrefeitura}/onibus/${dados!.idOnibus}/listaPresensa/$formattedDate/alunos/')
                        .where("id", isEqualTo: info)
                        .limit(1)
                        .get();

                    if (ref.docs.isNotEmpty) {
                      ref.docs[0].reference.update({"status": "confirmado"});
                    }
                  }
                },
                icon: const Icon(Icons.qr_code)),
          )
      ],
      bottom: TabBar(
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.transparent,
        physics: const BouncingScrollPhysics(),
        isScrollable: _numberOfTabs < 4 ? false : true,
        tabs: [
          for (int i = 0; i < _numberOfTabs; i++)
            Tab(
              text: '${listaData[i]['nome']}',
            ),
        ],
      ),
    );
  }

  Column tabsView(BuildContext context, List<dynamic> listaData) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height - 230,
          child: TabBarView(
            physics: const BouncingScrollPhysics(),
            children: [
              for (int i = 0; i < _numberOfTabs; i++)
                Column(children: [
                  SizedBox(
                    height: 30,
                    child: Center(
                      child: Text(
                          'Vagas disponíveis: ${int.parse(onibusInfo!.numero_vagas) - int.parse(listaData[i]['numerosAlunos'].toString())}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection(
                                'prefeituras/${dados!.idPrefeitura}/onibus/${dados!.idOnibus}/listaPresensa/${listaData[i]['nome']}/alunos')
                            .snapshots()
                            .asyncMap((querySnapshot1) async {
                          var querySnapshot2 = await FirebaseFirestore.instance
                              .collection(
                                  'prefeituras/${dados!.idPrefeitura}/users/')
                              .where('idOnibus', isEqualTo: dados!.idOnibus)
                              .get();
                          return [querySnapshot1, querySnapshot2];
                        }),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            if (snapshot.data != null) {
                              final snapshot1 = snapshot.data![0];
                              final snapshot2 = snapshot.data![1];

                              List<QueryDocumentSnapshot> sortedDocs1 =
                                  List<QueryDocumentSnapshot>.from(
                                      snapshot1.docs);

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
                                  final dados = i.data();
                                  mapzada[dados['id']] = dados['profilePic'];
                                }

                                return listaPresensa(sortedDocs1, mapzada);
                              } finally {
                                final mapzada = {};

                                for (var i in snapshot2.docs) {
                                  final dados = i.data();
                                  mapzada[dados['id']] = dados['profilePic'];
                                }
                              }
                            } else {
                              return Container();
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ])
            ],
          ),
        ),
        Expanded(
          child: SizedBox(
            child: Center(
              child: ElevatedButton(
                  onPressed: () {}, child: const Text("Adicionar Carona")),
            ),
          ),
        )
      ],
    );
  }

  ListView listaPresensa(
      List<QueryDocumentSnapshot<Object?>> sortedDocs, Map mapzada) {
    listaPresensaTodos = [sortedDocs, mapzada];

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
                if (data['id'] == dados!.id && data['data'] == formattedDate)
                  Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: IconButton(
                      onPressed: () async {
                        final aluno = sortedDocs[index].reference;
                        if (data['status'] == 'ausente') {
                          aluno.update({'status': 'confirmado'});
                        } else {
                          aluno.update({'status': 'ausente'});
                        }
                      },
                      icon: const Icon(Icons.highlight_remove_sharp),
                    ),
                  ),
              ]),
            ),
          ],
        );
      },
    );
  }

  readQrCode() async {
    String code = await FlutterBarcodeScanner.scanBarcode(
        "#FFFFFF", "Cancelar", false, ScanMode.QR);

    if (code != '') {
      setState(() {
        infoQr = code;
      });
    }
  }

  createLista() async {
    if (await checkIfExists(formattedDate)) {
      await atualizarLista();
    } else {
      QuerySnapshot<Map<String, dynamic>> alunoDados = await criarNovaLista();
      await enviarMensagem(alunoDados);
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> criarNovaLista() async {
    final usera = FirebaseFirestore.instance
        .collection(
            "prefeituras/${dados!.idPrefeitura}/onibus/${dados!.idOnibus}/listaPresensa/")
        .doc(formattedDate);

    final alunos = usera.collection('alunos');

    final alunoDados = await FirebaseFirestore.instance
        .collection("prefeituras/${dados!.idPrefeitura}/users/")
        .where('idOnibus', isEqualTo: dados!.idOnibus)
        .get();

    final numerosAlunos = alunoDados.docs.length;

    usera.set({'nome': formattedDate, 'numerosAlunos': numerosAlunos});

    for (var data in alunoDados.docs) {
      final pessoa = data.data();

      final aluno = alunos.doc(pessoa['nome']);
      aluno.set({
        'id': pessoa['id'],
        'nome': pessoa['nome'],
        'status': 'ausente',
        'data': formattedDate,
      });
    }
    return alunoDados;
  }

  Future<void> atualizarLista() async {
    final alunosQuery = await FirebaseFirestore.instance
        .collection("prefeituras/${dados!.idPrefeitura}/users/")
        .where('idOnibus', isEqualTo: dados!.idOnibus)
        .get()
        .then((value) => value.docs);

    final alunosData = alunosQuery.map((e) => e.data()).toList();

    final userQuery = await FirebaseFirestore.instance
        .collection(
            "prefeituras/${dados!.idPrefeitura}/onibus/${dados!.idOnibus}/listaPresensa/$formattedDate/alunos")
        .get()
        .then((value) => value.docs);

    final userData = userQuery.map((e) => e.data()['id']);
    int numeroAlunosNovos = 0;

    for (var info in alunosData) {
      if (!userData.contains(info['id'])) {
        numeroAlunosNovos++;
        await FirebaseFirestore.instance
            .collection(
                "prefeituras/${dados!.idPrefeitura}/onibus/${dados!.idOnibus}/listaPresensa/$formattedDate/alunos")
            .doc(info['nome'])
            .set({
          'id': info['id'],
          'nome': info['nome'],
          'status': 'ausente',
          'data': formattedDate,
        });
      }
    }

    if (numeroAlunosNovos != 0) {
      final usera = FirebaseFirestore.instance
          .collection(
              "prefeituras/${dados!.idPrefeitura}/onibus/${dados!.idOnibus}/listaPresensa/")
          .doc(formattedDate);

      var data = await usera.get().then((value) => value.data()) as Map;

      usera.set({
        'nome': formattedDate,
        'numerosAlunos':
            "${int.parse(data['numerosAlunos'].toString()) + numeroAlunosNovos}"
      });
    }
  }

  Future<bool> checkIfExists(data) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(
            "prefeituras/${dados!.idPrefeitura}/onibus/${dados!.idOnibus}/listaPresensa/")
        .where("nome", isEqualTo: formattedDate)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  enviarMensagem(alunoDados) {
    sendFcmMessage(alunoDados.docs);
  }
}
