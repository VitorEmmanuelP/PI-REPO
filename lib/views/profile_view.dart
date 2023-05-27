import 'package:flutter/material.dart';
import 'package:pi/models/user_data.dart';
import 'package:pi/utils/styles.dart';
import 'package:pi/widgets/profile_pic.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
            Row(
              children: [
                SizedBox(
                  height: 250,
                  width: MediaQuery.of(context).size.width / 2,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("Nome: ${dados!.nome}"),
                        Text("Telefone: ${dados!.telefone}"),
                      ]),
                ),
                SizedBox(
                  height: 250,
                  width: MediaQuery.of(context).size.width / 2,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("Faculdade: ${dados!.faculdade}"),
                        Text("Cursando: ${dados!.curso}"),
                      ]),
                ),
              ],
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
