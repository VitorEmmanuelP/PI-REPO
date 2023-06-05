import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pi/constants/routes.dart';
import 'package:pi/models/user_data.dart';
import 'package:intl/intl.dart';
import 'package:pi/utils/styles.dart';

class ListaPresensaView extends StatefulWidget {
  const ListaPresensaView({super.key});

  @override
  State<ListaPresensaView> createState() => _ListaPresensaViewState();
}

class _ListaPresensaViewState extends State<ListaPresensaView> {
  String name = '';
  UserData? dados;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      resizeToAvoidBottomInset: false,
      appBar: appBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Column(
              children: [searchBar(), listaAluno(context)],
            ),
          ),
        ),
      ),
    );
  }

  ListView listView(sortedDocs) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: sortedDocs.length,
      itemBuilder: (context, index) {
        var data = sortedDocs[index] as Map<String, dynamic>;

        if (data.isEmpty) {
          return Container(
            color: Colors.amber,
          );
        }

        if (name.isEmpty) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .pushNamed(presencaUnicaRoute, arguments: [dados, data]);
            },
            child: Column(
              children: [
                Container(
                  width: 5000,
                  height: 100,
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
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
        onTap: () {
          Navigator.of(context)
              .pushNamed(presencaUnicaRoute, arguments: [dados, data]);
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
        SizedBox(
          width: 100,
          height: 100,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text('${data['nome']}'),
          ),
        )
      ],
    );
  }

  SizedBox listaAluno(BuildContext context) {
    final UserData? args =
        ModalRoute.of(context)?.settings.arguments as UserData?;

    if (args != null) {
      dados = args;
    }
    return SizedBox(
        height: MediaQuery.of(context).size.height - 230,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(
                  'prefeituras/${dados!.idPrefeitura}/onibus/${dados!.idOnibus}/listaPresensa')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Erro ao carregar os dados'));
            } else {
              final listaTodasPresencas = snapshot.data!.docs;

              var listaTodasPresencasInfo = [];

              for (var i in listaTodasPresencas) {
                listaTodasPresencasInfo.add(i.data());
              }

              DateFormat format = DateFormat("dd-MM-yyyy");
              listaTodasPresencasInfo.sort((a, b) =>
                  format.parse(b['nome']).compareTo(format.parse(a['nome'])));

              return listView(listaTodasPresencasInfo);
            }
          },
        ));
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

  AppBar appBar() {
    return AppBar(
      title: const Text(
        "Todas as lista de presenças",
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Builder(
        builder: (context) {
          return IconButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                await Future.delayed(const Duration(milliseconds: 200));
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back));
        },
      ),
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
    );
  }
}
