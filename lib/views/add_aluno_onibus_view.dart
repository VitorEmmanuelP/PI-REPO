import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pi/utils/dados_users.dart';

class AddALunoONibusView extends StatefulWidget {
  const AddALunoONibusView({super.key});

  @override
  State<AddALunoONibusView> createState() => _AddALunoONibusViewState();
}

class _AddALunoONibusViewState extends State<AddALunoONibusView> {
  String name = '';
  Map? dadosOnibus;
  List nomes = [];
  List listaAlunos = [];

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      dadosOnibus = args;
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [searchBar(), listAlunos()],
        ),
      ),
    );
  }

  Card searchBar() {
    return Card(
      child: TextField(
        onChanged: (value) {
          setState(() {
            name = value;
          });
        },
        decoration: const InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
            prefixIcon: Icon(Icons.search),
            hintText: "Search.."),
      ),
    );
  }

  Container listAlunos() {
    return Container(
      height: MediaQuery.of(context).size.height - 230,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('prefeituras/${dadosOnibus!['idPrefeitura']}/users')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 70,
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            // snapshot.data!.docs.sort((a, b) {
            //   var onibusA = a.data() as Map;
            //   var onibusB = b.data() as Map;

            //   final onibusIdA = onibusA['onibusid'];
            //   final onibusIdB = onibusB['onibusid'];

            //   if (onibusIdA == null && onibusIdB == null) {
            //     return 0;
            //   } else if (onibusIdA == null) {
            //     return -1;
            //   } else if (onibusIdB == null) {
            //     return 1;
            //   } else {
            //     return onibusA['nome']
            //         .toString()
            //         .toUpperCase()
            //         .compareTo(onibusB['nome'].toString().toUpperCase());
            //   }
            // });
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
                  var data = sortedDocs[index].data() as Map<String, dynamic>;

                  if (data.isEmpty) {
                    return Container(
                      color: Colors.amber,
                    );
                  }

                  if (name.isEmpty) {
                    nomes = data['nome'].split(' ');

                    return Column(children: [
                      Container(
                        width: 5000,
                        height: 100,
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(border: Border.all(width: 2)),
                        child: Row(children: [
                          data['profilePic'] != ''
                              ? CircleAvatar(
                                  backgroundColor: Colors.red,
                                  radius: 60,
                                  backgroundImage:
                                      NetworkImage(data['profilePic']),
                                )
                              : CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  radius: 60,
                                  child: Text("${nomes[0][0]}${nomes[1][0]}"),
                                ),
                          Text('${data['nome']}'),
                          const Spacer(),
                          data['onibusid'] == ''
                              ? IconButton(
                                  onPressed: () {
                                    final id = data['id'];

                                    addAlunoBus(id);
                                  },
                                  icon: const Icon(
                                    Icons.add_sharp,
                                  ))
                              : IconButton(
                                  onPressed: () {
                                    final id = data['id'];

                                    removerAlunoBus(id);
                                  },
                                  icon: const Icon(Icons.check))
                        ]),
                      )
                    ]);
                  }

                  if (data['nome']
                      .toString()
                      .toLowerCase()
                      .startsWith(name.toLowerCase())) {
                    return Column(children: [
                      Container(
                        width: 5000,
                        height: 100,
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(border: Border.all(width: 2)),
                        child: Row(children: [
                          data['profilePic'] != ''
                              ? CircleAvatar(
                                  backgroundColor: Colors.red,
                                  radius: 60,
                                  backgroundImage:
                                      NetworkImage(data['profilePic']),
                                )
                              : CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  radius: 60,
                                  child: Text("${nomes[0][0]}${nomes[1][0]}"),
                                ),
                          Text('${data['nome']}'),
                          const Spacer(),
                          IconButton(
                              onPressed: () {
                                // print(snapshot.data!.docs[index].data());
                              },
                              icon: const Icon(
                                Icons.add_sharp,
                              ))
                        ]),
                      )
                    ]);
                  }
                  return Container();
                });
          }
        },
      ),
    );
  }

  addAlunoBus(id) {
    final usera = FirebaseFirestore.instance
        .collection("prefeituras/${dadosOnibus!['idPrefeitura']}/users/")
        .doc(id);

    usera.update({'onibusid': dadosOnibus!['id'].toString()});

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.green,
      content: Text("Usuario adicionado ao onibus"),
    ));
  }

  removerAlunoBus(id) {
    final usera = FirebaseFirestore.instance
        .collection("prefeituras/${dadosOnibus!['idPrefeitura']}/users/")
        .doc(id);

    usera.update({'onibusid': ''});

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red,
      content: Text("Usuario Removido"),
    ));
  }

  loadData() async {
    final maplist = await getListShared('listaAlunos');
    maplist.removeWhere((mapa) => mapa.length == 0);

    setState(() {
      listaAlunos = maplist;
    });
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        "Adicionar Alunos",
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }
}
