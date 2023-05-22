bool isCPFValid(String cpf) {
  // Remove qualquer caractere não numérico do CPFr
  cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');

  // Verifica se o CPF possui 11 dígitos
  if (cpf.length != 11) {
    return false;
  }

  // Verifica se todos os dígitos do CPF são iguais (CPF inválido)
  if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) {
    return false;
  }

  // Verifica o primeiro dígito verificador do CPF
  int sum = 0;
  for (int i = 0; i < 9; i++) {
    sum += int.parse(cpf[i]) * (10 - i);
  }
  int digit1 = 11 - (sum % 11);
  if (digit1 >= 10) {
    digit1 = 0;
  }
  if (digit1 != int.parse(cpf[9])) {
    return false;
  }

  // Verifica o segundo dígito verificador do CPF
  sum = 0;
  for (int i = 0; i < 10; i++) {
    sum += int.parse(cpf[i]) * (11 - i);
  }
  int digit2 = 11 - (sum % 11);
  if (digit2 >= 10) {
    digit2 = 0;
  }
  if (digit2 != int.parse(cpf[10])) {
    return false;
  }

  return true;
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
