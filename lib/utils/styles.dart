import 'package:flutter/material.dart';

InputDecoration estiloTextField(String label,
    {bool erro = false, String msg = '', placeholder}) {
  return InputDecoration(
    labelText: label,
    errorText: erro ? msg : null,
    labelStyle: const TextStyle(
        color: Color.fromARGB(100, 69, 69, 69), fontWeight: FontWeight.bold),
    enabledBorder: fazerBorda(),
    focusedBorder: fazerBorda(),
    errorBorder: fazerBorda(erro: erro),
    focusedErrorBorder: fazerBorda(erro: erro),
  );
}

OutlineInputBorder fazerBorda({bool erro = false}) {
  return OutlineInputBorder(
    borderSide: BorderSide(
        color: erro ? Colors.red : const Color.fromARGB(100, 69, 69, 69)),
    borderRadius: BorderRadius.circular(10),
  );
}

styleButton() {
  return OutlinedButton.styleFrom(
    minimumSize: const Size.fromHeight(80),
    backgroundColor: Colors.blue,
    side: const BorderSide(color: Colors.blue, width: 2),
  );
}

const scaffoldColor = Colors.white;
const blue = Colors.blue;

const textColor = Colors.white;
