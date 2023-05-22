import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pi/models/user_data.dart';
import 'package:pi/utils/dados_users.dart';
import 'package:pi/utils/validador_login.dart';

import '../utils/show_error_message.dart';
import '../utils/validadores_genericos.dart';

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
  bool? checkBoxValue1 = false;
  late Uint8List qrCodeBytes;

  var nomesError = false;
  var cpfError = false;
  var telefoneError = false;
  var dataError = false;
  var checkBoxErro = true;

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
              checkButtons(),
              addButton(context, maskFormatterCpf, maskFormatTelef,
                  maskFormatterData),
            ],
          ),
        ),
      ),
    );
  }

  Center checkButtons() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Checkbox(
                value: checkBoxValue1,
                onChanged: (newValue) {
                  setState(() {
                    checkBoxValue1 = newValue;
                  });
                },
              ),
              Row(
                children: const [
                  Text('O aluno é um cordernador'),
                ],
              ),
            ],
          ),
        ],
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
          bool isConnected = await checkInternetConnection();

          if (isConnected) {
            FocusScope.of(context).unfocus();
            final nome = _nomeCompleto.text;
            final cpf = maskFormatterCpf.unmaskText(_cpf.text);
            final faculdade = _faculdade.text;
            final cursoAluno = _cursoAluno.text;
            final telefone = maskFormatTelef.unmaskText(_telefone.text);
            final data = maskFormatterData.unmaskText(_data.text);
            final status = checkBoxValue1! ? 'cordenador' : 'aluno';

            validarRegistros(nome, cpf, telefone, data);
            //generateQrCode(nome);

            if (checarErros()) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
                content: Text("Adicionado"),
              ));

              final prefeitura = await getUser();
              final docRef = await FirebaseFirestore.instance
                  .collection("prefeituras/${prefeitura.id}/users/")
                  .add({
                'nome': nome,
                'cpf': cpf,
                'faculdade': faculdade,
                'cursoAluno': cursoAluno,
                'telefone': telefone,
                'profilePic': '',
                'senha': data,
                'data': data,
                'status': status,
                'idOnibus': '',
                'id': '',
                'idPrefeitura': prefeitura.id,
                'token': '',
              });

              final idCurrent = docRef.id.toString();

              final usera = FirebaseFirestore.instance
                  .collection("prefeituras/${prefeitura.id}/users/")
                  .doc(idCurrent);

              usera.update({'id': idCurrent});

              final registro = UserData(
                nome: nome,
                cpf: cpf,
                faculdade: faculdade,
                curso: cursoAluno,
                telefone: telefone,
                profilePic: '',
                senha: data,
                data: data,
                status: 'aluno',
                idOnibus: '',
                id: idCurrent,
                idPrefeitura: 'prefeitura.id',
                token: '',
              );

              await addListaAluno(registro);

              await FirebaseFirestore.instance.collection("users").add({
                'cpf': cpf,
                'dataNascimento': data,
                'senha': data,
                'idPrefeitura': prefeitura.id,
                'id': idCurrent,
              });

              //Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
                content: Text("Erro"),
              ));
            }
          } else {
            await showErrorMessage(context, "Not internet");
          }
        },
        child: const Text("Adicionar"));
  }

  Future<String> getQrCodeImageFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/qr_code.png';

    return imagePath;
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
    final mapList = await getListUsers();

    if (!mapList.contains(registro)) {
      mapList.add(registro);

      saveListModels('listaAlunos', mapList);
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
      if (!validarData(data)) {
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
