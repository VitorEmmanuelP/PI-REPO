import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../utils/check_internet.dart';
import '../utils/styles.dart';
import '../utils/validadores_genericos.dart';
import '../widgets/app_bar.dart';

class EsqueceSenhaView extends StatefulWidget {
  const EsqueceSenhaView({super.key});

  @override
  State<EsqueceSenhaView> createState() => _EsqueceSenhaViewState();
}

class _EsqueceSenhaViewState extends State<EsqueceSenhaView> {
  late final TextEditingController _cpf;
  late final TextEditingController _dataNascimento;
  late final TextEditingController _novaSenha;

  bool cpfError = false;
  bool dataNascimentoError = false;
  bool novaSenhaError = false;

  @override
  void initState() {
    _cpf = TextEditingController();
    _dataNascimento = TextEditingController();
    _novaSenha = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _cpf.dispose();
    _dataNascimento.dispose();
    _novaSenha.dispose();
    super.dispose();
  }

  final maskFormatterCpf = MaskTextInputFormatter(
      mask: '###-###-###-##', filter: {"#": RegExp(r'[0-9]')});
  final maskFormatterData = MaskTextInputFormatter(
      mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: scaffoldColor,
        appBar: appBar("Esquece minha senha"),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Column(children: [
              const Padding(
                padding: EdgeInsets.only(top: 30),
                child: Text("Redefinir senha",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text(
                  "Informe seu cpf e data de nascimento para qual deseja redefinir a senha",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 60.0, left: 10, right: 10),
                child: TextField(
                  controller: _cpf,
                  keyboardType: TextInputType.number,
                  inputFormatters: [maskFormatterCpf],
                  decoration: estiloTextField("CPF",
                      erro: cpfError, msg: "Digite um CPF valido"),
                  onChanged: (value) {
                    if (cpfError) {
                      setState(() {
                        cpfError = false;
                      });
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 60.0, left: 10, right: 10),
                child: TextField(
                  controller: _dataNascimento,
                  keyboardType: TextInputType.number,
                  inputFormatters: [maskFormatterData],
                  decoration: estiloTextField("Data de Nascimento",
                      erro: dataNascimentoError,
                      msg: "Digite uma data de nascimento valida"),
                  onChanged: (value) {
                    if (dataNascimentoError) {
                      setState(() {
                        dataNascimentoError = false;
                      });
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 60.0, left: 10, right: 10),
                child: TextField(
                  controller: _novaSenha,
                  keyboardType: TextInputType.number,
                  decoration: estiloTextField("Nova Senha",
                      erro: novaSenhaError,
                      msg: "Digite uma senha de no maximo 8 numeros"),
                  onChanged: (value) {
                    if (novaSenhaError) {
                      setState(() {
                        novaSenhaError = false;
                      });
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 50, bottom: 20.0, right: 40, left: 40),
                child: ElevatedButton(
                    style: styleButton(),
                    onPressed: () async {
                      bool isConnected = await checkInternetConnection();

                      if (isConnected) {
                        final cpf = maskFormatterCpf.unmaskText(_cpf.text);
                        final data =
                            maskFormatterData.unmaskText(_dataNascimento.text);
                        final novaSenha = _novaSenha.text;

                        validarRegistros(cpf, data, novaSenha);

                        if (checarErros()) {
                          final db = await FirebaseFirestore.instance
                              .collection("users")
                              .where("cpf", isEqualTo: cpf)
                              .where("dataNascimento", isEqualTo: data)
                              .limit(1)
                              .get();

                          final a = db.docs.first.reference;

                          a.update({"senha": novaSenha});
                        }
                      }
                    },
                    child: const Text("Redefinir")),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  bool checarErros() {
    if (!cpfError && !dataNascimentoError) {
      return true;
    } else {
      return false;
    }
  }

  void validarRegistros(String cpf, String data, String novaSenha) {
    setState(() {
      if (!isCPFValid(cpf)) {
        cpfError = true;
      }
      if (!validarData(data)) {
        dataNascimentoError = true;
      }
      if (!validarSenha(novaSenha)) {
        novaSenhaError = true;
      }
    });
  }

  bool validarSenha(String input) {
    if (input.length > 8) {
      return true;
    } else {
      return false;
    }
  }
}
