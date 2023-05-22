import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pi/constants/routes.dart';

import '../models/user_data.dart';

class ListaPagamentosView extends StatefulWidget {
  const ListaPagamentosView({super.key});

  @override
  State<ListaPagamentosView> createState() => _ListaPagamentosViewState();
}

class _ListaPagamentosViewState extends State<ListaPagamentosView> {
  UserData? userDados;

  @override
  Widget build(BuildContext context) {
    final UserData? args =
        ModalRoute.of(context)?.settings.arguments as UserData?;

    if (args != null) {
      userDados = args;
    }
    return Scaffold(
        appBar: appBar(),
        body: userDados!.idOnibus != ''
            ? listaPix()
            : const Center(
                child: Text(
                    "Precisa estar cadastrado em um onibus para ver a lista")));
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> listaPix() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(
              'prefeituras/${userDados!.idPrefeitura}/onibus/${userDados!.idOnibus}/pagamentos')
          .where("criador", isNotEqualTo: '')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final dados = snapshot.data!.docs;
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: dados.length,
          itemBuilder: (context, index) {
            final data = dados[index].data();

            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(pagamentoRoute, arguments: data);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      width: 5000,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.black),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            child: Image.asset('assets/images/pix.png'),
                          ),
                          Text(data['criador']),
                          Text("\$${data['valor']} reais")
                        ],
                      ),
                    ),
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        "Lista de Pagamentos",
        style: TextStyle(color: Colors.black),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }
}
