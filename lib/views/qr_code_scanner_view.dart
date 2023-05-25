import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:pi/models/user_data.dart';
import 'package:pi/utils/dados_users.dart';

class QRCodeScannerScreen extends StatefulWidget {
  const QRCodeScannerScreen({super.key});

  @override
  _QRCodeScannerScreenState createState() => _QRCodeScannerScreenState();
}

class _QRCodeScannerScreenState extends State<QRCodeScannerScreen> {
  String infoQr = '';
  String? formattedDate;
  UserData? dados;

  @override
  void initState() {
    loadDados();
    DateTime now = DateTime.now();
    formattedDate = DateFormat('dd-MM-yyyy').format(now);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                await readQrCode();

                var info = '=$infoQr';

                info = info.split('').reversed.join();
                info = utf8.decode(base64.decode(info));

                if (infoQr != '-1') {
                  final ref = await FirebaseFirestore.instance
                      .collection(
                          'prefeituras/${dados!.idPrefeitura}/onibus/${dados!.idOnibus}/listaPresensa/$formattedDate/alunos/')
                      .where("id", isEqualTo: info)
                      .limit(1)
                      .get();

                  if (ref.docs.isNotEmpty) {
                    ref.docs[0].reference.update({"status": "confirmado"});
                  }
                }
              },
              icon: const Icon(Icons.qr_code),
              label: const Text("Validar"),
            )
          ],
        ),
      ),
    );
  }

  loadDados() async {
    final prev = await getUser();
    setState(() {
      dados = prev;
    });
  }

  readQrCode() async {
    String code = await FlutterBarcodeScanner.scanBarcode(
        "#FFFFFF", "Cancelar", false, ScanMode.QR);

    if (code != '') {
      setState(() {
        infoQr = code;
      });
    }
  }
}
