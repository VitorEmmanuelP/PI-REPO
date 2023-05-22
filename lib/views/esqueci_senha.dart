import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../utils/check_internet.dart';
import '../utils/validadores_genericos.dart';

class EsqueceSenhaView extends StatefulWidget {
  const EsqueceSenhaView({super.key});

  @override
  State<EsqueceSenhaView> createState() => _EsqueceSenhaViewState();
}

class _EsqueceSenhaViewState extends State<EsqueceSenhaView> {
  @override
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

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: appBar(),
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
                padding: const EdgeInsets.only(top: 50.0),
                child: OutlinedButton(
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

  InputDecoration estiloTextField(String label,
      {bool erro = false, String msg = ''}) {
    return InputDecoration(
      labelText: label,
      errorText: erro ? msg : null,
      labelStyle:
          const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      enabledBorder: fazerBorda(),
      focusedBorder: fazerBorda(),
      errorBorder: fazerBorda(erro: erro),
      focusedErrorBorder: fazerBorda(erro: erro),
    );
  }

  OutlineInputBorder fazerBorda({bool erro = false}) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: erro ? Colors.red : Colors.black),
      borderRadius: BorderRadius.circular(10),
    );
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
      return false;
    } else
      return true;
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
