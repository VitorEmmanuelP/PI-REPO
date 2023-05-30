import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pi/models/user_data.dart';
import 'package:pi/utils/dados_users.dart';
import 'package:pi/utils/show_error_message.dart';
import 'package:pi/utils/styles.dart';

import '../utils/check_internet.dart';
import '../widgets/app_bar.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  Map<String, dynamic>? dados;
  List<String>? nome = [];
  Future<Map?>? dadosFuture;
  String qrData = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      dados = args;
      nome = dados?['nome'].split(' ');
    }

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: appBar("Profile"),
      body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 190,
                  width: 190,
                  child: ClipOval(
                      child: CachedNetworkImage(
                    imageUrl: dados!['profilePic'],
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 70,
                      child: Center(
                        child: Text(
                          "${nome![0][0].toUpperCase()}${nome![1][0].toUpperCase()}",
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
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          children: [
                            const Text("Nome",
                                style: TextStyle(color: Colors.blue)),
                            Text(dados!["nome"],
                                style: const TextStyle(
                                    color: Color.fromARGB(100, 69, 69, 69))),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Text("Telefone",
                                style: TextStyle(color: Colors.blue)),
                            Text(dados!["telefone"],
                                style: const TextStyle(
                                    color: Color.fromARGB(100, 69, 69, 69))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                const Text("Faculdade",
                                    style: TextStyle(color: Colors.blue)),
                                Text(dados!["faculdade"],
                                    style: const TextStyle(
                                        color:
                                            Color.fromARGB(100, 69, 69, 69))),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                const Text("Curso",
                                    style: TextStyle(color: Colors.blue)),
                                Text(dados!["cursoAluno"],
                                    style: const TextStyle(
                                        color:
                                            Color.fromARGB(100, 69, 69, 69))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final bool shouldDelete = await showDeleteDialog(context);
                    bool isConnected = await checkInternetConnection();

                    if (shouldDelete) {
                      if (isConnected) {
                        await deletarUser();

                        Navigator.of(context).pop();
                      } else {
                        await showErrorMessage(context, 'Internet Missing');
                      }
                    }
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),
          )),
    );
  }

  Future<void> deletarUser() async {
    final user = FirebaseFirestore.instance
        .collection('prefeituras/${dados!['idPrefeitura']}/users/')
        .doc(dados!['id']);

    user.delete();

    final userId = await FirebaseFirestore.instance
        .collection('users')
        .where('cpf', isEqualTo: dados!['cpf'])
        .limit(1)
        .snapshots()
        .first;

    final userLogin = FirebaseFirestore.instance
        .collection('users')
        .doc(userId.docs.first.id);

    userLogin.delete();

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('images/${dados!['id']}/${dados!['id']}');

    storageRef.delete();

    atualizarStored();
  }

  atualizarStored() async {
    final List<UserData> listaAlunos = await getListUsers();

    listaAlunos.removeWhere((mapa) => mapa.id == dados!['id']);

    saveListModels('listaAlunos', listaAlunos);
  }
}
