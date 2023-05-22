import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/payload_pix.dart';

class PagamentoPreviewView extends StatefulWidget {
  const PagamentoPreviewView({super.key});

  @override
  State<PagamentoPreviewView> createState() => _PagamentoPreviewViewState();
}

class _PagamentoPreviewViewState extends State<PagamentoPreviewView> {
  PayloadPix? payload;

  @override
  Widget build(BuildContext context) {
    final PayloadPix? args =
        ModalRoute.of(context)?.settings.arguments as PayloadPix?;

    payload = args;

    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: MyQrCode(qrData: payload!.getPayload()),
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
                    child: Text(payload!.getPayload()),
                  ),
                ),
              ),
            ),
            OutlinedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: payload!.getPayload()));
                },
                child: const Text("COPIAR CHAVE PIX"))
          ],
        )),
      ),
    );
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
        "Esquece minha senha",
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

  MyQrCode({required this.qrData});

  @override
  Widget build(BuildContext context) {
    return QrImage(
      data: qrData,
      version: QrVersions.auto,
      size: 200.0,
    );
  }
}
