import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pi/utils/dados_users.dart';

import '../utils/validador_registro.dart';

class RegistrarAlunoView extends StatefulWidget {
  const RegistrarAlunoView({super.key});

  @override
  State<RegistrarAlunoView> createState() => _RegistrarAlunoViewState();
}

class _RegistrarAlunoViewState extends State<RegistrarAlunoView> {
  late final TextEditingController _nomeCompleto;
  late final TextEditingController _cpf;
  late final TextEditingController _faculdade;
  late final TextEditingController _cursoAluno;
  late final TextEditingController _telefone;
  late final TextEditingController _data;

  var nomesError = false;
  var cpfError = false;
  var telefoneError = false;
  var dataError = false;

  @override
  void initState() {
    _nomeCompleto = TextEditingController();
    _cpf = TextEditingController();
    _faculdade = TextEditingController();
    _cursoAluno = TextEditingController();
    _telefone = TextEditingController();
    _data = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _nomeCompleto.dispose();
    _cpf.dispose();
    _faculdade.dispose();
    _cursoAluno.dispose();
    _telefone.dispose();
    _data.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maskFormatTelef = MaskTextInputFormatter(
        mask: '(##)#####-####', filter: {"#": RegExp(r'[0-9]')});

    final maskFormatterData = MaskTextInputFormatter(
        mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});

    final maskFormatterCpf = MaskTextInputFormatter(
        mask: '###-###-###-##', filter: {"#": RegExp(r'[0-9]')});

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar(),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: <Widget>[
              nomeTextField(),
              cpfTextField(maskFormatterCpf),
              faculdadeTextField(),
              cursoTextField(),
              numeroTextField(maskFormatTelef),
              dataTextField(maskFormatterData),
              addButton(context, maskFormatterCpf, maskFormatTelef,
                  maskFormatterData),
            ],
          ),
        ),
      ),
    );
  }

  OutlinedButton addButton(
      BuildContext context,
      MaskTextInputFormatter maskFormatterCpf,
      MaskTextInputFormatter maskFormatTelef,
      MaskTextInputFormatter maskFormatterData) {
    return OutlinedButton(
        onPressed: () async {
          FocusScope.of(context).unfocus();
          final nome = _nomeCompleto.text;
          final cpf = maskFormatterCpf.unmaskText(_cpf.text);
          final faculdade = _faculdade.text;
          final cursoAluno = _cursoAluno.text;
          final telefone = maskFormatTelef.unmaskText(_telefone.text);
          final data = maskFormatterData.unmaskText(_data.text);
          //final corAvatar = getRandomColor();

          validarRegistros(nome, cpf, telefone, data);

          if (checarErros()) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              content: Text("Adicionado"),
            ));

            final id = await getInfoUser();

            final docRef = await FirebaseFirestore.instance
                .collection("prefeituras/${id['id']}/users/")
                .add({
              'nome': nome,
              'cpf': cpf,
              'faculdade': faculdade,
              'cursoAluno': cursoAluno,
              'telefone': telefone,
              'profilePic': '',
              'senha': data,
              'data': data,
              'status': 'aluno',
              'onibusid': '',
              'id': '',
              'idPrefeitura': id['id']
            });

            final idCurrent = docRef.id.toString();

            final usera = FirebaseFirestore.instance
                .collection("prefeituras/${id['id']}/users/")
                .doc(idCurrent);

            usera.update({'id': idCurrent});

            Map registro = {
              'nome': nome,
              'cpf': cpf,
              'faculdade': faculdade,
              'cursoAluno': cursoAluno,
              'telefone': telefone,
              'profilePic': '',
              'senha': data,
              'data': data,
              'status': 'aluno',
              'onibusid': '',
              'id': idCurrent,
              'idPrefeitura': id['id']
            };

            await addListaAluno(registro);

            await FirebaseFirestore.instance.collection("users").add({
              'cpf': cpf,
              'senha': data,
              'idPrefeitura': id['id'],
              'id': idCurrent,
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              content: Text("Erro"),
            ));
          }
          Navigator.of(context).pop();
          //mudarTela();
        },
        child: const Text("Adicionar"));
  }

  Padding dataTextField(MaskTextInputFormatter maskFormatterData) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _data,
        keyboardType: TextInputType.number,
        inputFormatters: [maskFormatterData],
        decoration: estiloTextField("Data de nascimento",
            erro: dataError, msg: "Digite uma data valida"),
        onChanged: (value) {
          if (dataError) {
            setState(() {
              dataError = false;
            });
          }
        },
      ),
    );
  }

  Padding numeroTextField(MaskTextInputFormatter maskFormatTelef) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _telefone,
        keyboardType: TextInputType.number,
        inputFormatters: [maskFormatTelef],
        decoration: estiloTextField("Telefone",
            erro: telefoneError, msg: "Digite um numero completo"),
        onChanged: (value) {
          if (telefoneError) {
            setState(() {
              telefoneError = false;
            });
          }
        },
      ),
    );
  }

  Padding cursoTextField() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _cursoAluno,
        decoration: estiloTextField("Curso do Aluno"),
      ),
    );
  }

  Padding faculdadeTextField() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _faculdade,
        decoration: estiloTextField("Faculdade"),
      ),
    );
  }

  Padding cpfTextField(MaskTextInputFormatter maskFormatterCpf) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _cpf,
        keyboardType: TextInputType.number,
        inputFormatters: [maskFormatterCpf],
        decoration:
            estiloTextField("CPF", erro: cpfError, msg: "Digite um CPF valido"),
        onChanged: (value) {
          if (cpfError) {
            setState(() {
              cpfError = false;
            });
          }
        },
      ),
    );
  }

  Padding nomeTextField() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _nomeCompleto,
        decoration: estiloTextField("Nome Completo",
            erro: nomesError, msg: "Digite pelo menos o Nome e Sobrenome"),
        onChanged: (value) {
          if (nomesError) {
            setState(() {
              nomesError = false;
            });
          }
        },
      ),
    );
  }

  addListaAluno(registro) async {
    final mapList = await getListShared('listaAlunos');

    if (!mapList.contains(registro)) {
      mapList.add(registro);

      setListShared('listaAlunos', mapList);
    }
  }

  mudarTela() {
    Navigator.of(context).pop();
  }

  bool checarErros() {
    if (!cpfError && !nomesError && !telefoneError && !dataError) {
      return true;
    } else {
      return false;
    }
  }

  void validarRegistros(String nome, String cpf, String telefone, String data) {
    nome = nome.trim();
    List<String> nomes = nome.split(' ');

    setState(() {
      if (nomes.length < 2) {
        nomesError = true;
      }
      if (!isCPFValid(cpf)) {
        cpfError = true;
      }
      if (telefone.length < 11) {
        telefoneError = true;
      }
      if (data.length < 8) {
        setState(() {
          dataError = true;
        });
      }
    });
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

  String getRandomColor() {
    Random random = Random();
    final cor =
        "${random.nextInt(256)},${random.nextInt(256)},${random.nextInt(256)}";
    return cor;
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        "Register",
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }
}
