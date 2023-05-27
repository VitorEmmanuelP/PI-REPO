import 'package:flutter/material.dart';

InputDecoration estiloTextField(String label,
    {bool erro = false, String msg = '', placeholder}) {
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

final scaffoldColor = Colors.white;
