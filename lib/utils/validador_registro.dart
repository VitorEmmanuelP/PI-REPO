import 'package:pi/utils/validadores_genericos.dart';

Future validarRegistro(
    String nome, String cpf, String telefone, String data) async {
  List<String> erro = [];
  List<String> nomes = nome.split(' ');

  if (nomes.length < 2) {
    erro.add('Erro nome');
  }
  if (!isCPFValid(cpf)) {
    erro.add('Erro cpf');
  }
  if (telefone.length < 11) {
    erro.add('Erro cpf');
  }
  if (data.length < 8) {
    erro.add('Erro cpf');
  }
}

bool validarData(String input) {
  try {
    List<String> partes = input.split('/');
    int dia = int.parse(partes[0]);
    int mes = int.parse(partes[1]);
    int ano = int.parse(partes[2]);

    if (ano < 1 || ano > 9999) return false;
    if (mes < 1 || mes > 12) return false;
    if (dia < 1 || dia > 31) return false;

    return true;
  } catch (e) {
    return false;
  }
}
