import 'package:flutter/material.dart';

class InfoBusView extends StatefulWidget {
  const InfoBusView({super.key});

  @override
  State<InfoBusView> createState() => _InfoBusViewState();
}

class _InfoBusViewState extends State<InfoBusView> {
  Map? dados;
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      dados = args;
    }

    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
            child: Column(
          children: <Widget>[
            Text('${dados!['motorista']}'),
          ],
        )),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        "Infomação do onibus",
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }
}
