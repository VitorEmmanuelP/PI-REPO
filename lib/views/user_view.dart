import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pi/models/user_data.dart';
import 'package:pi/utils/dados_users.dart';
import 'package:pi/utils/show_error_message.dart';

import '../utils/check_internet.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  Map? dados;

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
    }

    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
            child: Column(
          children: <Widget>[
            Text("${dados!['nome']}"),
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
                child: const Text('Delete'))
          ],
        )),
      ),
    );
  }

  Future<void> deletarUser() async {
    final user = FirebaseFirestore.instance
        .collection('prefeituras/${dados!['idPrefeitura']}/users/')
        .doc('${dados!['id']}');

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

  Color getRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256), // Red value (0-255)
      random.nextInt(256), // Green value (0-255)
      random.nextInt(256), // Blue value (0-255)
      1.0,
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        "Profile",
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }
}
