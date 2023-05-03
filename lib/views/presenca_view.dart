import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pi/utils/dados_users.dart';

class PresencaView extends StatefulWidget {
  const PresencaView({super.key});

  @override
  State<PresencaView> createState() => _PresencaViewState();
}

class _PresencaViewState extends State<PresencaView> {
  int _numberOfTabs = 0;
  Map? dados;
  List nome = [];
  String formattedDate = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    DateTime now = DateTime.now();

    if (args != null) {
      dados = args;
      formattedDate = DateFormat('dd-MM-yyyy').format(now);
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(
              '/prefeituras/SiAA09DYyS5UgeJtYG8r/onibus/YvQQCyRr3EZHXRhd0yCx/listaPresensa')
          .orderBy('nome')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar os dados'));
        }

        _numberOfTabs = snapshot.data!.docs.length;
        final tabsData = snapshot.data!.docs;

        final listaData = [];

        for (var i in tabsData) {
          listaData.add(i.data());
        }

        DateFormat format = DateFormat("dd-MM-yyyy");
        listaData.sort((a, b) =>
            format.parse(b['nome']).compareTo(format.parse(a['nome'])));

        return DefaultTabController(
          length: _numberOfTabs,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Minha App',
                  style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: IconButton(
                      onPressed: () {
                        createLista();
                      },
                      icon: const Icon(Icons.add)),
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
            ),
            body: tabsView(context, listaData),
          ),
        );
      },
    );
  }

  TabBarView tabsView(BuildContext context, List<dynamic> listaData) {
    return TabBarView(
      physics: BouncingScrollPhysics(),
      children: [
        for (int i = 0; i < _numberOfTabs; i++)
          SizedBox(
            height: MediaQuery.of(context).size.height - 230,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(
                      'prefeituras/SiAA09DYyS5UgeJtYG8r/onibus/YvQQCyRr3EZHXRhd0yCx/listaPresensa/${listaData[i]['nome']}/alunos')
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

                  return listaPresensa(sortedDocs);
                }
              },
            ),
          )
      ],
    );
  }

  ListView listaPresensa(List<QueryDocumentSnapshot<Object?>> sortedDocs) {
    return ListView.builder(
      itemCount: sortedDocs.length,
      itemBuilder: (context, index) {
        var data = sortedDocs[index].data() as Map<String, dynamic>;

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
                data['profilePic'] != ''
                    ? CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 60,
                        backgroundImage: NetworkImage(data['profilePic']),
                      )
                    : const CircleAvatar(
                        radius: 70,
                        child: Center(
                          child: Text(
                            "A",
                            style: TextStyle(color: Colors.white, fontSize: 35),
                          ),
                        ),
                      ),
                Text('${data['nome']}\n ${data['status']}'),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: IconButton(
                      onPressed: () async {
                        final aluno = sortedDocs[index].reference;
                        if (data['status'] == 'ausente') {
                          aluno.update({'status': 'confirmado'});
                        } else {
                          aluno.update({'status': 'ausente'});
                        }
                      },
                      icon: const Icon(Icons.highlight_remove_sharp)),
                ),
              ]),
            ),
          ],
        );
      },
    );
  }

  createLista() async {
    final listadeAlunos = await getListShared('listaAlunos');
    listadeAlunos.removeWhere((mapa) => mapa.length == 0);

    final usera = FirebaseFirestore.instance
        .collection(
            "prefeituras/${dados!['idPrefeitura']}/onibus/${dados!['idOnibus']}/listaPresensa/")
        .doc('$formattedDate');

    usera.set({'nome': formattedDate});

    final alunos = usera.collection('alunos');

    for (var pessoa in listadeAlunos) {
      final aluno = alunos.doc(pessoa['nome']);

      aluno.set({
        'id': '${pessoa['id']}',
        'nome': '${pessoa['nome']}',
        'profilePic': '${pessoa['profilePic']}',
        'idOnibus': '${pessoa['idOnibus']}',
        'status': 'ausente'
      });
    }
  }
  // }

  //   loadDados() async {
  //     final listadeAlunos = await getListShared('listaAlunos');
  //     listadeAlunos.removeWhere((mapa) => mapa.length == 0);
  //     //final map = await getInfoUser();

  //     // setState(() {
  //     //   dados = map;
  //     // });

  //     final usera = FirebaseFirestore.instance
  //         .collection(
  //             "prefeituras/${dados!['idPrefeitura']}/onibus/${dados!['idOnibus']}/listaPresensa/")
  //         .doc('$formattedDate');

  //     usera.set({});

  //     final alunos = usera.collection('alunos');

  //     for (var pessoa in listadeAlunos) {
  //       final aluno = alunos.doc(pessoa['nome']);

  //       aluno.set({
  //         'id': '${pessoa['id']}',
  //         'nome': '${pessoa['nome']}',
  //         'profilePic': '${pessoa['profilePic']}',
  //         'idOnibus': '${pessoa['idOnibus']}',
  //         'status': 'ausente'
  //       });
  //     }
  //   }
  // }
}
