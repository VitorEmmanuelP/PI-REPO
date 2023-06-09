import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:pi/constants/routes.dart';
import 'package:pi/models/bus_data.dart';

import 'package:pi/models/user_data.dart';
import 'package:pi/utils/styles.dart';

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
  int horas = 0;
  String? infoQr;
  bool isLoading = true;
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
      horas = int.parse(DateFormat('HHmm').format(now));
      //horas = 1200;
      formattedDate = DateFormat('dd-MM-yyyy').format(now);
    }

    return dados!.idOnibus != ''
        ? presensa()
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
              title: const Text("Lista de presença",
                  style: TextStyle(color: Colors.black)),
            ),
            body: naoCadrastado(),
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
              backgroundColor: scaffoldColor,
              appBar: appBar(listaData),
              body: _numberOfTabs != 0
                  ? tabsView(context, listaData)
                  : const Center(
                      child: Text("Nao existe lista de presença"),
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
                            'prefeituras/${dados!.idPrefeitura}/onibus/${dados!.idOnibus}/listaPresensa/$formattedDate/${listaData[0]["ida"] > horas ? "ida" : "volta"}/')
                        .where("id", isEqualTo: info)
                        .limit(1)
                        .get();

                    if (ref.docs.isNotEmpty) {
                      ref.docs[0].reference.update({"status": "confirmado"});
                    } else {}
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
              height: 50,
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
          height: MediaQuery.of(context).size.height - 250,
          child: TabBarView(
            physics: const BouncingScrollPhysics(),
            children: [
              for (int i = 0; i < _numberOfTabs; i++)
                Column(children: [
                  SizedBox(
                    height: 30,
                    child: Center(
                      child: Text(
                          int.parse(onibusInfo!.numeroVagas) -
                                      int.parse(listaData[i]['numerosAlunos']
                                          .toString()) >
                                  0
                              ? ' ${listaData[i]["ida"] > horas ? "Lista da Ida" : "Lista da Volta"} - Vagas disponíveis: ${int.parse(onibusInfo!.numeroVagas) - int.parse(listaData[i]['numerosAlunos'].toString())}'
                              : "O onibus esta cheio.",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection(
                                'prefeituras/${dados!.idPrefeitura}/onibus/${dados!.idOnibus}/listaPresensa/${listaData[i]['nome']}/${listaData[i]["ida"] > horas ? "ida" : "volta"}')
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
                              if (inde != null) {
                                sortedDocs1.insert(0, snapshot1.docs[inde!]);
                                final mapzada = {};

                                for (var i in snapshot2.docs) {
                                  final dados = i.data();
                                  mapzada[dados['id']] = dados['profilePic'];
                                }

                                return listaPresensa(sortedDocs1, mapzada);
                              } else {
                                final mapzada = {};

                                for (var i in snapshot2.docs) {
                                  final dados = i.data();
                                  mapzada[dados['id']] = dados['profilePic'];
                                }
                                return listaPresensa(sortedDocs1, mapzada);
                              }
                            }
                          }
                          return Container();
                        },
                      ),
                    ),
                  ),
                ])
            ],
          ),
        ),
        dados!.status == "coordenador"
            ? Expanded(
                child: SizedBox(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 10, bottom: 20.0, right: 20, left: 20),
                      child: ElevatedButton(
                          style: styleButton(),
                          onPressed: () {
                            Navigator.of(context).pushNamed(registerCaronaRoute,
                                arguments: [dados, onibusInfo]);
                          },
                          child: const Text("Adicionar Carona")),
                    ),
                  ),
                ),
              )
            : Container()
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

        final nome = data['nome'].toUpperCase().trim().split(' ');
        return Column(
          children: [
            Container(
              width: 5000,
              height: 120,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    width: 2,
                    color: data['status'] == 'ausente'
                        ? Colors.red
                        : Colors.green),
              ),
              child: Row(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
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
                              backgroundColor: Colors.transparent,
                              radius: 60,
                              backgroundImage: imageProvider,
                            ),
                          )
                        : data["status"] == "ausente" ||
                                data["status"] == "confirmado"
                            ? CircleAvatar(
                                radius: 60,
                                child: Center(
                                  child: Text(
                                    nome.length == 1
                                        ? nome[0][0].toUpperCase()
                                        : "${nome[0][0].toUpperCase()}${nome[1][0].toUpperCase()}",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 35),
                                  ),
                                ),
                              )
                            : const CircleAvatar(
                                backgroundColor: Colors.red,
                                backgroundImage:
                                    AssetImage("assets/images/avatar.jpg"),
                              ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: RichText(
                    text: TextSpan(
                      text: '${data["nome"]}\n',
                      style: const TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${data["status"]}',
                          style: TextStyle(
                              color: data['status'] == 'ausente'
                                  ? Colors.red
                                  : Colors.green),
                        ),
                      ],
                    ),
                  ),
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
      QuerySnapshot<Map<String, dynamic>> alunoDados =
          await criarNovaLista(formattedDate);
      await enviarMensagem(alunoDados);
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> criarNovaLista(a) async {
    final usera = FirebaseFirestore.instance
        .collection(
            "prefeituras/${dados!.idPrefeitura}/onibus/${dados!.idOnibus}/listaPresensa/")
        .doc(a);

    final alunosIda = usera.collection('ida');
    final alunosVolta = usera.collection('volta');

    final alunoDados = await FirebaseFirestore.instance
        .collection("prefeituras/${dados!.idPrefeitura}/users/")
        .where('idOnibus', isEqualTo: dados!.idOnibus)
        .get();

    final onibusDados = await FirebaseFirestore.instance
        .collection("prefeituras/${dados!.idPrefeitura}/onibus/")
        .where('id', isEqualTo: dados!.idOnibus)
        .get();

    final onibusData = onibusDados.docs.first;

    final numerosAlunos = alunoDados.docs.length;

    usera.set({
      'nome': a,
      'numerosAlunos': numerosAlunos,
      "ida": onibusData["ida"],
    });

    for (var data in alunoDados.docs) {
      final pessoa = data.data();

      final aluno = alunosIda.doc(pessoa['nome']);
      aluno.set({
        'id': pessoa['id'],
        'nome': pessoa['nome'],
        'status': 'ausente',
        'data': formattedDate,
      });
    }

    for (var data in alunoDados.docs) {
      final pessoa = data.data();

      final aluno = alunosVolta.doc(pessoa['nome']);
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
            "prefeituras/${dados!.idPrefeitura}/onibus/${dados!.idOnibus}/listaPresensa/$formattedDate/ida")
        .get()
        .then((value) => value.docs);

    final userData = userQuery.map((e) => e.data()['id']);
    int numeroAlunosNovos = 0;

    for (var info in alunosData) {
      if (!userData.contains(info['id'])) {
        numeroAlunosNovos++;
        await FirebaseFirestore.instance
            .collection(
                "prefeituras/${dados!.idPrefeitura}/onibus/${dados!.idOnibus}/listaPresensa/$formattedDate/ida")
            .doc(info['nome'])
            .set({
          'id': info['id'],
          'nome': info['nome'],
          'status': 'ausente',
          'data': formattedDate,
        });

        await FirebaseFirestore.instance
            .collection(
                "prefeituras/${dados!.idPrefeitura}/onibus/${dados!.idOnibus}/listaPresensa/$formattedDate/volta")
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
      final onibusDados = await FirebaseFirestore.instance
          .collection("prefeituras/${dados!.idPrefeitura}/onibus/")
          .where('id', isEqualTo: dados!.idOnibus)
          .get();

      final onibusData = onibusDados.docs.first;

      final usera = FirebaseFirestore.instance
          .collection(
              "prefeituras/${dados!.idPrefeitura}/onibus/${dados!.idOnibus}/listaPresensa/")
          .doc(formattedDate);

      var data = await usera.get().then((value) => value.data()) as Map;

      usera.set(
        {
          'nome': formattedDate,
          'numerosAlunos':
              "${int.parse(data['numerosAlunos'].toString()) + numeroAlunosNovos}",
          "ida": onibusData["ida"],
        },
      );
    }
  }

  Future<bool> checkIfExists(data) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(
            "prefeituras/${dados!.idPrefeitura}/onibus/${dados!.idOnibus}/listaPresensa/")
        .where("nome", isEqualTo: data)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  enviarMensagem(alunoDados) {
    sendFcmMessage(
        alunoDados.docs, 'Uma nova lista foi criada, corra para marca preseça');
  }

  Center naoCadrastado() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Text(
              "Você ainda não esta cadastrado em nehum ônibus",
              style: TextStyle(fontSize: 15),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.0),
            child: Text(
              "Peça a sua prefeitura que te cadastre",
              style: TextStyle(fontSize: 15),
            ),
          )
        ],
      ),
    );
  }
}
