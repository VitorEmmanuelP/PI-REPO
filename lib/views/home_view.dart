import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pi/constants/routes.dart';
import 'package:pi/utils/dadosUsers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Map? dados;
  List listaAlunos = [];

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar(),
        body: dados?['status'] == 'prefeitura'
            ? prefeituraHomeView(context)
            : alunoHomeView(context));
  }

  Center prefeituraHomeView(BuildContext context) {
    return Center(
        child: Column(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/logo.png",
          height: 250,
        ),
        Container(
          padding: const EdgeInsets.all(20),
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(registerRoute);
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(80),
              side: const BorderSide(color: Colors.black, width: 2),
            ),
            child: const Text(
              "Registrar Aluno",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(listaAlunoRoute);
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(80),
              side: const BorderSide(color: Colors.black, width: 2),
            ),
            child: const Text(
              "Lista de Alunos",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    ));
  }

  Center alunoHomeView(BuildContext context) {
    return Center(
        child: Column(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/logo.png",
          height: 250,
        ),
        Container(
          padding: const EdgeInsets.all(20),
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(agendaRoute);
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(80),
              side: const BorderSide(color: Colors.black, width: 2),
            ),
            child: const Text(
              "AGENDAR",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(presencaRoute);
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(80),
              side: const BorderSide(color: Colors.black, width: 2),
            ),
            child: const Text(
              "PRESENÇA",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(infoBusRoute);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(80),
                side: const BorderSide(color: Colors.black, width: 2),
              ),
              child: const Text(
                "INFO. Ônibus",
                style: TextStyle(color: Colors.black),
              )),
        ),
      ],
    ));
  }

  void loadData() async {
    final dadosString = await getInfoUser();
    setState(() {
      dados = dadosString;
    });
    if (dadosString['status'] == 'prefeitura') {
      final snapshot = await FirebaseFirestore.instance
          .collection("prefeituras/${dadosString['id']}/users/")
          .get();

      for (var doc in snapshot.docs) {
        listaAlunos.add(doc.data());
      }
    }

    SharedPreferences shared = await SharedPreferences.getInstance();

    final encodedList = listaAlunos.map((item) => jsonEncode(item)).toList();

    shared.setStringList('listaAlunos', encodedList);
  }

  AppBar appBar() {
    return AppBar(
      leading: Builder(
        builder: (context) {
          return IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(profileRoute);
            },
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Colors.black,
            ),
            iconSize: 36.0,
          );
        },
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black,
            )),
        IconButton(
            onPressed: () async {
              SharedPreferences shared = await SharedPreferences.getInstance();

              //shared.setString('dados', 'Falso');

              Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
                (route) => false,
              );
            },
            icon: const Icon(
              Icons.logout_sharp,
              color: Colors.black,
            ))
      ],
    );
  }
}
