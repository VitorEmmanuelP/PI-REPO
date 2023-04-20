import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pi/utils/dadosUsers.dart';
import 'package:pi/widgets/profile_pic.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Map? dados;
  List<String> nome = [];
  Future<Map?>? dadosFuture;

  @override
  void initState() {
    super.initState();
    dadosFuture = loadDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
            child: Column(
          children: <Widget>[
            const ProfilePictureWidget(),
            FutureBuilder<Map?>(
              // Pass the Future to the future property of FutureBuilder
              future: dadosFuture,
              builder: (BuildContext context, AsyncSnapshot<Map?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  if (nome.isEmpty) {
                    return Container();
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Text('${nome[0]} ${nome[1]}',
                          style: TextStyle(fontSize: 20)),
                    );
                  }
                }
              },
            )
          ],
        )),
      ),
    );
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

  Future<Map?> loadDados() async {
    final userdata = await getInfoUser();

    setState(() {
      dados = userdata;
      nome = dados?['nome'].split(' ');
    });
    return dados;
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
