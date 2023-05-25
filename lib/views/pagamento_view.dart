import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:qr_flutter/qr_flutter.dart';

class PagamentoView extends StatefulWidget {
  const PagamentoView({super.key});

  @override
  State<PagamentoView> createState() => _PagamentoViewState();
}

class _PagamentoViewState extends State<PagamentoView> {
  QueryDocumentSnapshot<Map<String, dynamic>>? ref;
  Map<String, dynamic>? payload;
  String status = '';
  List<String> data = [];

  @override
  Widget build(BuildContext context) {
    final QueryDocumentSnapshot<Map<String, dynamic>>? args =
        ModalRoute.of(context)?.settings.arguments
            as QueryDocumentSnapshot<Map<String, dynamic>>?;

    if (args != null) {
      ref = args;
      payload = args.data();

      criarData(payload!['data']);
    }

    criarData(payload!['data']);
    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: MyQrCode(qrData: payload!['qrcode']),
            ),
            SizedBox(
              width: 300,
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(payload!['criador']),
                        Text("\$${payload!['valor']}"),
                      ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("${data[1]} as ${data[0]}"),
                    ],
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  status == '' ? payload!['status'] : status,
                  style: TextStyle(
                      color: payload!['status'] == 'pendente' && status == ''
                          ? Colors.red
                          : Colors.green),
                ),
                IconButton(
                    onPressed: () {
                      ref!.reference.update({'status': 'Confirmado'});
                      setState(() {
                        status = 'Confirmado';
                      });
                    },
                    icon: const Icon(Icons.check))
              ],
            ),
            Row(
              children: [
                numeracao('1'),
                texto("Abra o app do seu banco ou seu app de pagamentos."),
              ],
            ),
            Row(
              children: [
                numeracao('2'),
                texto("Busque á opção de pagar com pix."),
              ],
            ),
            Row(
              children: [
                numeracao('3'),
                texto("Escanei o QR Code ou copie e cole o seguinte código."),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.lightBlue),
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(payload!['qrcode']),
                  ),
                ),
              ),
            ),
            OutlinedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: payload!['qrcode']));
                },
                child: const Text("COPIAR CHAVE PIX"))
          ],
        )),
      ),
    );
  }

  criarData(String dataHora) {
    data.add(dataHora.substring(11));
    data.add(dataHora.substring(0, 10));
  }

  Expanded texto(String text) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 10),
        child: Text(
          text,
          softWrap: true,
        ),
      ),
    );
  }

  Padding numeracao(String numero) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.lightBlue, width: 2),
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
            child: Text(
          numero,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        )),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        "Pagamento detalhes",
        style: TextStyle(color: Colors.black),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      backgroundColor: Colors.white,
      elevation: 0,
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
