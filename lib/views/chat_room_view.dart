// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/user_data.dart';
import '../utils/enviar_mensagens.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({super.key});

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  dynamic dados;
  String? idPrefeitura;

  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dynamic args = ModalRoute.of(context)?.settings.arguments as dynamic;
    if (args != null) {
      dados = args;
      if (dados.runtimeType == UserData) {
        idPrefeitura = dados.idPrefeitura;
      } else {
        idPrefeitura = dados.id;
      }
    }
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    idPrefeitura == "SiAA09DYyS5UgeJtYG8r"
                        ? "https://portalfacilarquivos.blob.core.windows.net/uploads/TRESMARIAS/imgOrig/%7BAAC2DCBA-C47E-A8CC-6DDB-BCBD4AAB5BEE%7D.jpg"
                        : "https://lagoaformosa.mg.gov.br/wp-content/uploads/2016/03/brasao.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                dados.runtimeType == UserData
                    ? dados!.nomePrefeitura
                    : dados.prefeituraNome,
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        body: idPrefeitura != '' ? chatRoomMesages(context) : naoCadrastado());
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

  SafeArea chatRoomMesages(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(
                          "prefeituras/${dados.runtimeType == UserData ? dados!.idPrefeitura : dados.id}/chatroom")
                      .orderBy("createdOn", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot =
                            snapshot.data as QuerySnapshot;

                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          reverse: true,
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            final currentMessage = dataSnapshot.docs[index]
                                .data() as Map<String, dynamic>;

                            return Row(
                              mainAxisAlignment:
                                  (currentMessage["senderId"] == dados!.id)
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        maxWidth: 200, minWidth: 150),
                                    child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: (currentMessage["senderId"] ==
                                                  dados!.id)
                                              ? Color.fromARGB(255, 8, 123, 217)
                                              : Color.fromARGB(
                                                  255, 105, 157, 246),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            currentMessage["senderName"] !=
                                                    dados!.nome
                                                ? Text(
                                                    currentMessage["senderName"]
                                                        .toString(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : Container(),
                                            const SizedBox(height: 5),
                                            Text(
                                              currentMessage["text"].toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  currentMessage["dataHora"]
                                                      .toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                              "An error occured! Please check your internet connection."),
                        );
                      } else {
                        return const Center(
                          child: Text("Say hi to your new friend"),
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 20.0, left: 10, right: 10, top: 20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(255, 233, 230, 230)),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        controller: messageController,
                        maxLines: null,
                        decoration: const InputDecoration(
                            border: InputBorder.none, hintText: "Mensage"),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        sendMessage();
                      },
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "") {
      DateTime now = DateTime.now();
      String formattedTime = DateFormat('dd/MM/yyyy - HH:mm').format(now);

      if (dados.runtimeType == UserData) {
        FirebaseFirestore.instance
            .collection("prefeituras/${dados!.idPrefeitura}/chatroom")
            .doc()
            .set({
          "createdOn": DateTime.now(),
          "dataHora": formattedTime,
          "senderName": dados!.nome,
          "senderId": dados!.id,
          "text": msg,
        });
      } else {
        FirebaseFirestore.instance
            .collection("prefeituras/${dados!.id}/chatroom")
            .doc()
            .set({
          "createdOn": DateTime.now(),
          "dataHora": formattedTime,
          "senderName": dados!.nome,
          "senderId": dados!.id,
          "text": msg,
        });
      }
      final ultimaMensagem = await FirebaseFirestore.instance
          .collection(
              "prefeituras/${dados.runtimeType == UserData ? dados!.idPrefeitura : dados.id}/chatroom")
          .doc("ultimaMensagem")
          .get()
          .then((value) => value.data());

      final ultimahora = ultimaMensagem!['horario'];

      final horaAtual = int.parse(DateFormat('HHmm').format(now));
      if (ultimahora + 10 < horaAtual) {
        final alunoDados = await FirebaseFirestore.instance
            .collection("prefeituras/${dados!.idPrefeitura}/users/")
            .where('idOnibus', isEqualTo: dados!.idOnibus)
            .get();

        await enviarMensagem(alunoDados);

        await FirebaseFirestore.instance
            .collection(
                "prefeituras/${dados.runtimeType == UserData ? dados!.idPrefeitura : dados.id}/chatroom")
            .doc("ultimaMensagem")
            .update({"horario": horaAtual});
      }
    }
  }

  enviarMensagem(alunoDados) {
    sendFcmMessage(
        alunoDados.docs, "Uma nova mensagem foi enviada no chatroom");
  }
}
