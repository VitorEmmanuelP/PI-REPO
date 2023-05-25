import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pi/models/bus_data.dart';
import 'package:pi/utils/dados_users.dart';

class AddALunoONibusView extends StatefulWidget {
  const AddALunoONibusView({super.key});

  @override
  State<AddALunoONibusView> createState() => _AddALunoONibusViewState();
}

class _AddALunoONibusViewState extends State<AddALunoONibusView> {
  String name = '';
  Map<String, dynamic>? dadosOnibus;
  List nomes = [];
  //List listaAlunos = [];

  @override
  void initState() {
    //loadData();
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

  Center searchBar() {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 35,
        child: TextField(
          onChanged: (value) {
            setState(() {
              name = value;
            });
          },
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(10)),
              prefixIcon: const Icon(Icons.search),
              hintText: "Search.."),
        ),
      ),
    );
  }

  SizedBox listAlunos() {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 230,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('prefeituras/${dadosOnibus!['idPrefeitura']}/users')
            .where('idOnibus', isEqualTo: '')
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
                              ? SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: CachedNetworkImage(
                                    imageUrl: data['profilePic'],
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      radius: 70,
                                      child: Center(
                                        child: Text(
                                          "'${nomes[0][0].toUpperCase()}${nomes[1][0].toUpperCase()}'",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 35),
                                        ),
                                      ),
                                    ),
                                    imageBuilder: (context, imageProvider) =>
                                        CircleAvatar(
                                      backgroundColor: Colors.red,
                                      radius: 60,
                                      backgroundImage: imageProvider,
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: CircleAvatar(
                                    radius: 70,
                                    child: Center(
                                      child: Text(
                                        "${nomes[0][0].toUpperCase()}${nomes[1][0].toUpperCase()}",
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 35),
                                      ),
                                    ),
                                  ),
                                ),

                          //   ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Text('${data['nome']}'),
                          ),
                          const Spacer(),
                          IconButton(
                              onPressed: () {
                                final id = data['id'];

                                addAlunoBus(id);
                              },
                              icon: const Icon(
                                Icons.add_sharp,
                              ))
                        ]),
                      )
                    ]);
                  }

                  if (data['nome']
                      .toString()
                      .toLowerCase()
                      .startsWith(name.toLowerCase())) {
                    nomes = data['nome'].split(' ');
                    return Column(children: [
                      Container(
                        width: 5000,
                        height: 100,
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(border: Border.all(width: 2)),
                        child: Row(children: [
                          data['profilePic'] != ''
                              ? SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: CachedNetworkImage(
                                    imageUrl: data['profilePic'],
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      radius: 70,
                                      child: Center(
                                        child: Text(
                                          "'${nomes[0][0].toUpperCase()}${nomes[1][0].toUpperCase()}'",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 35),
                                        ),
                                      ),
                                    ),
                                    imageBuilder: (context, imageProvider) =>
                                        CircleAvatar(
                                      backgroundColor: Colors.red,
                                      radius: 60,
                                      backgroundImage: imageProvider,
                                    ),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 70,
                                  child: Center(
                                    child: Text(
                                      "${nomes[0][0].toUpperCase()}${nomes[1][0].toUpperCase()}",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 35),
                                    ),
                                  ),
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

    usera.update({'idOnibus': dadosOnibus!['id'].toString()});

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      behavior: SnackBarBehavior.fixed,
      duration: Duration(milliseconds: 500),
      backgroundColor: Colors.green,
      content: Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Center(
            child: Text(
          "Usuario adicionado ao onibus",
        )),
      ),
    ));
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
