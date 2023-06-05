import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pi/constants/routes.dart';
import 'package:pi/models/prefeitura_data.dart';
import 'package:pi/models/user_data.dart';

import 'package:pi/utils/dados_users.dart';
import 'package:pi/utils/styles.dart';
import 'package:pi/utils/validador_login.dart';

import 'package:pi/views/user_view.dart';

import '../utils/show_error_message.dart';
import '../widgets/app_bar.dart';

class ListaAlunoView extends StatefulWidget {
  const ListaAlunoView({super.key});

  @override
  State<ListaAlunoView> createState() => _ListaAlunoViewState();
}

class _ListaAlunoViewState extends State<ListaAlunoView> {
  String name = '';
  PrefeituraData? dados;
  List<UserData> listaDeAlunos = [];
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
      backgroundColor: scaffoldColor,
      resizeToAvoidBottomInset: false,
      appBar: appBar("Lista de Alunos"),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [searchBar(), listaAluno(context), addAluno(context)],
          ),
        ),
      ),
    );
  }

  SizedBox listaAluno(BuildContext context) {
    final PrefeituraData? args =
        ModalRoute.of(context)?.settings.arguments as PrefeituraData?;

    if (args != null) {
      dados = args;
    }
    return SizedBox(
        height: MediaQuery.of(context).size.height - 300,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('prefeituras/${dados!.id}/users')
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

              return listView(sortedDocs);
            }
          },
        ));
  }

  ListView listView(List<QueryDocumentSnapshot<Object?>> sortedDocs) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: sortedDocs.length,
      itemBuilder: (context, index) {
        var data = sortedDocs[index].data() as Map<String, dynamic>;
        nome = data['nome'].split(' ');

        if (data.isEmpty) {
          return Container(
            color: Colors.amber,
          );
        }

        if (name.isEmpty) {
          return GestureDetector(
            onTap: () async {
              Navigator.of(context)
                  .pushNamed(userRoute, arguments: data)
                  .then((value) {
                loadLista();
              });
            },
            child: Column(
              children: [
                Container(
                  width: 5000,
                  height: 120,
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      border: Border.all(width: 2),
                      borderRadius: BorderRadius.circular(10)),
                  child: cardUser(data),
                ),
              ],
            ),
          );
        }
        return logicaDeBusca(data, context);
      },
    );
  }

  StatelessWidget logicaDeBusca(
      Map<String, dynamic> data, BuildContext context) {
    if (data['nome'].toString().toLowerCase().startsWith(name.toLowerCase())) {
      return GestureDetector(
        onTap: () async {
          Navigator.of(context)
              .push(MaterialPageRoute(
            builder: (context) => const UserView(),
            settings: RouteSettings(
              arguments: data,
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
                child: cardUser(data)),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Row cardUser(Map<String, dynamic> data) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 100,
            height: 100,
            child: data['profilePic'] != ''
                ? CachedNetworkImage(
                    imageUrl: data['profilePic'],
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 70,
                      child: Center(
                        child: Text(
                          "${nome[0][0].toUpperCase()}${nome[1][0].toUpperCase()}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 35),
                        ),
                      ),
                    ),
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 60,
                      backgroundImage: imageProvider,
                    ),
                  )
                : CircleAvatar(
                    radius: 70,
                    child: Center(
                      child: Text(
                        "${nome[0][0].toUpperCase()}${nome[1][0].toUpperCase()}",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 35),
                      ),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child:
              Text('${data['nome']}\n${data['status']} ${data['cursoAluno']}'),
        ),
      ],
    );
  }

  SizedBox searchBar() {
    return SizedBox(
      height: 75,
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
    );
  }

  Padding addAluno(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 20, bottom: 20.0, right: 20, left: 20),
      child: OutlinedButton(
          style: styleButton(),
          onPressed: () async {
            bool isConnected = await checkInternetConnection();

            if (isConnected) {
              Navigator.of(context).pushNamed(registerAlunoRoute).then((value) {
                loadLista();
              });
            } else {
              await showErrorMessage(context, "Not internet");
            }
          },
          child: Row(
            children: const [
              Expanded(
                child: Center(
                  child: Text(
                    'Adicionar Alunos',
                    style: TextStyle(color: textColor),
                  ),
                ),
              ),
              Center(
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
              ),
            ],
          )),
    );
  }

  loadLista() async {
    final mapList = await getListUsers();
    bool connected = await checkInternetConnection();

    setState(() {
      listaDeAlunos = mapList;
      isConnected = connected;
    });
  }
}
