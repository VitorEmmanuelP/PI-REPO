import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pi/utils/styles.dart';

import '../models/user_data.dart';
import '../widgets/app_bar.dart';

class InfoOnibusAlunoView extends StatefulWidget {
  const InfoOnibusAlunoView({super.key});

  @override
  State<InfoOnibusAlunoView> createState() => _InfoOnibusAlunoViewState();
}

class _InfoOnibusAlunoViewState extends State<InfoOnibusAlunoView> {
  UserData? dados;
  List<String>? nome = [];

  @override
  Widget build(BuildContext context) {
    final UserData? args =
        ModalRoute.of(context)?.settings.arguments as UserData?;

    if (args != null) {
      dados = args;
    }
    return Scaffold(
        backgroundColor: scaffoldColor,
        appBar: appBar("Informações do Ônibus"),
        body: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("prefeituras/${dados!.idPrefeitura}/onibus/")
                    .where('id', isEqualTo: dados!.idOnibus)
                    .limit(1)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    if (snapshot.data != null) {
                      final data = snapshot.data!.docs.first.data();
                      nome = data['motorista'].trim().split(" ");

                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 190,
                              width: 190,
                              child: ClipOval(
                                child: data['profilePic'] != ''
                                    ? CachedNetworkImage(
                                        imageUrl: data['profilePic'],
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          radius: 70,
                                          child: Center(
                                            child: Text(
                                              "${nome![0][0].toUpperCase()}${nome![1][0].toUpperCase()}",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 35),
                                            ),
                                          ),
                                        ),
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                CircleAvatar(
                                          backgroundColor: Colors.red,
                                          radius: 60,
                                          backgroundImage: imageProvider,
                                        ),
                                      )
                                    : const CircleAvatar(
                                        backgroundColor: Colors.blue,
                                        backgroundImage: AssetImage(
                                            "assets/images/avatar.jpg"),
                                        radius: 70,
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Column(
                                children: [
                                  const Text("Nome",
                                      style: TextStyle(color: Colors.blue)),
                                  Text(data['motorista'],
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
                                  const Text("Destino",
                                      style: TextStyle(color: Colors.blue)),
                                  Text(data['destino'],
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
                                  const Text("Placa",
                                      style: TextStyle(color: Colors.blue)),
                                  Text(data['placa'],
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
                                  const Text("Numero de Vagas",
                                      style: TextStyle(color: Colors.blue)),
                                  Text(data['numeroVagas'],
                                      style: const TextStyle(
                                          color:
                                              Color.fromARGB(100, 69, 69, 69))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }

                  return const Center(child: Text('Erro ao carregar os dados'));
                },
              )
            ],
          ),
        ));
  }
}
