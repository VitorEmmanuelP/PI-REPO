import 'package:flutter/material.dart';
import 'package:pi/models/user_data.dart';
import 'package:pi/utils/styles.dart';
import 'package:pi/widgets/profile_pic.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../widgets/app_bar.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  UserData? dados;
  List<String>? nome = [];
  Future<Map?>? dadosFuture;

  @override
  Widget build(BuildContext context) {
    final UserData? args =
        ModalRoute.of(context)?.settings.arguments as UserData?;
    if (args != null) {
      dados = args;
      nome = dados?.nome.split(' ');
    }

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: appBar("Perfil"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
            child: Column(
          children: <Widget>[
            SizedBox(
              height: 190,
              width: 190,
              child: ProfilePictureWidget(),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  const Text("Nome", style: TextStyle(color: Colors.blue)),
                  Text(dados!.nome,
                      style: const TextStyle(
                          color: Color.fromARGB(100, 69, 69, 69))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text("Telefone", style: TextStyle(color: Colors.blue)),
                  Text(dados!.telefone,
                      style: const TextStyle(
                          color: Color.fromARGB(100, 69, 69, 69))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text("Faculdade", style: TextStyle(color: Colors.blue)),
                  Text(dados!.faculdade,
                      style: const TextStyle(
                          color: Color.fromARGB(100, 69, 69, 69))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text("Curso", style: TextStyle(color: Colors.blue)),
                  Text(dados!.curso,
                      style: const TextStyle(
                          color: Color.fromARGB(100, 69, 69, 69))),
                ],
              ),
            ),
            SizedBox(
              height: 330,
              width: double.infinity,
              child: Center(
                  child: MyQrCode(
                      qrData: dados!.qrCode.split('').reversed.join())),
            ),
          ],
        )),
      ),
    );
  }
}

class MyQrCode extends StatelessWidget {
  final String qrData;

  const MyQrCode({super.key, required this.qrData});

  @override
  Widget build(BuildContext context) {
    return QrImage(
      data: qrData,
      version: QrVersions.auto,
      size: 200.0,
    );
  }
}
