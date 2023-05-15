import 'package:flutter/material.dart';
import 'package:pi/models/payload_pix.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Pix extends StatefulWidget {
  const Pix({super.key});

  @override
  State<Pix> createState() => _PixState();
}

class _PixState extends State<Pix> {
  late final TextEditingController _cpf;
  late final TextEditingController _valor;

  @override
  void initState() {
    _cpf = TextEditingController();
    _valor = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _cpf.dispose();
    _valor.dispose();

    super.dispose();
  }

  String data = '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
              child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: _cpf,
                  decoration: const InputDecoration(label: Text('Cpf')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: _valor,
                  decoration: const InputDecoration(label: Text('Valor')),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final cpfText = _cpf.text;
                  final valor = _valor.text;

                  final a = PayloadPix(
                    pixKey: cpfText,
                    description: 'Pagamento do pedido 123456',
                    merchantName: 'William Costa',
                    merchantCity: 'SAO PAULO',
                    amount: valor,
                    txId: 'WDEV1234',
                  );

                  setState(() {
                    data = a.getPayload();
                  });
                },
                child: const Text("AD"),
              ),
              MyQrCode(qrData: data),
              Image.network(
                  'https://static.mundoeducacao.uol.com.br/mundoeducacao/conteudo_legenda/15a48fa8afb888ff7015bdd563056729.jpg')
            ],
          )),
        ),
      ),
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
