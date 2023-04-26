import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pi/utils/dados_users.dart';
import 'package:pi/utils/show_error_message.dart';

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
    print(dados);
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
                  print(dados);
                  final bool shouldDelete = await showDeleteDialog(context);

                  if (shouldDelete) {
                    final user = FirebaseFirestore.instance
                        .collection(
                            'prefeituras/${dados!['idPrefeitura']}/users/')
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
                        .doc('${userId.docs.first.id}');

                    userLogin.delete();

                    atualizarStored();

                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Delete'))
          ],
        )),
      ),
    );
  }

  atualizarStored() async {
    final List listaAlunos = await getListShared('listaAlunos');

    listaAlunos.removeWhere((mapa) => mapa['id'] == dados!['id']);

    setListShared('listaAlunos', listaAlunos);
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
