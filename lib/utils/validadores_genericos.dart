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

bool validarData(String dateOfBirth) {
  // Verifique se a data de nascimento tem o comprimento esperado (8 caracteres)
  if (dateOfBirth.length != 8) {
    return false;
  }
  // Converte as partes em números inteiros
  int? day = int.tryParse(dateOfBirth.substring(0, 2));
  int? month = int.tryParse(dateOfBirth.substring(2, 4));
  int? year = int.tryParse(dateOfBirth.substring(4));

  // Verifique se o dia, mês e ano são válidos
  if (day == null || month == null || year == null) {
    return false;
  }

  // Verifique se o dia está entre 1 e 31
  if (day < 1 || day > 31) {
    return false;
  }

  // Verifique se o mês está entre 1 e 12
  if (month < 1 || month > 12) {
    return false;
  }

  // Verifique se o ano está no intervalo esperado
  if (year < 1900) {
    return false;
  }

  // A data de nascimento é válida
  return true;
}
