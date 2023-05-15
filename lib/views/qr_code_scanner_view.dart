import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class QRCodeScannerScreen extends StatefulWidget {
  @override
  _QRCodeScannerScreenState createState() => _QRCodeScannerScreenState();
}

class _QRCodeScannerScreenState extends State<QRCodeScannerScreen> {
  String infoQr = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            if (infoQr != '') Text(infoQr),
            ElevatedButton.icon(
              onPressed: () {
                readQrCode();
              },
              icon: const Icon(Icons.qr_code),
              label: const Text("Validar"),
            )
          ],
        ),
      ),
    );
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
