import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pi/constants/routes.dart';
import 'package:pi/utils/styles.dart';

import '../models/user_data.dart';
import '../widgets/app_bar.dart';

class ListaPagamentosView extends StatefulWidget {
  const ListaPagamentosView({super.key});

  @override
  State<ListaPagamentosView> createState() => _ListaPagamentosViewState();
}

class _ListaPagamentosViewState extends State<ListaPagamentosView> {
  UserData? userDados;
  String name = '';

  @override
  Widget build(BuildContext context) {
    final UserData? args =
        ModalRoute.of(context)?.settings.arguments as UserData?;

    if (args != null) {
      userDados = args;
    }
    return Scaffold(
        backgroundColor: scaffoldColor,
        appBar: appBar("Lista de Pagamentos"),
        body: userDados!.idOnibus != ''
            ? listaPix()
            : const Center(
                child: Text(
                    "Precisa estar cadastrado em um onibus para ver a lista")));
  }

  Column listaPix() {
    return Column(
      children: [
        searchBar(),
        Expanded(
          child: StreamBuilder(
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

                var listaData = [];

                for (var i in dados) {
                  var dict = i.data();

                  listaData.add(dict);
                }

                DateFormat format = DateFormat("dd-MM-yyyy");

                listaData.sort((a, b) =>
                    format.parse(b['data']).compareTo(format.parse(a['data'])));

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: listaData.length,
                  itemBuilder: (context, index) {
                    final data = listaData[index];

                    if (name.isEmpty) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(pagamentoRoute,
                                  arguments: [data, userDados]);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Container(
                                width: 5000,
                                height: 120,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 2, color: Colors.black),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: card(data),
                              ),
                            ),
                          )
                        ],
                      );
                    }

                    return logicaDeBusca(data, context);
                  },
                );
              }),
        ),
      ],
    );
  }

  StatelessWidget logicaDeBusca(
      QueryDocumentSnapshot<Map<String, dynamic>> dados, BuildContext context) {
    Map<String, dynamic> dadosPix = dados.data();
    String data = dadosPix['data'].substring(0, 10);

    if (data.toString().toLowerCase().startsWith(name.toLowerCase())) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(pagamentoRoute, arguments: dados);
        },
        child: Column(
          children: [
            Container(
                width: 5000,
                height: 100,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(width: 2),
                ),
                child: card(dados)),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Row card(data) {
    return Row(
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: Image.asset('assets/images/pix.png'),
        ),
        RichText(
          text: TextSpan(
            text: "${data['criador']}\n",
            style: const TextStyle(color: Colors.black),
            children: <TextSpan>[
              TextSpan(
                text: "\$${data['valor']} reais",
              ),
            ],
          ),
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
}
