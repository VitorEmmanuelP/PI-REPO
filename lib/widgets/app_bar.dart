import 'package:flutter/material.dart';

AppBar appBar(String text) {
  return AppBar(
    title: Text(
      text,
      style: const TextStyle(color: Colors.black),
    ),
    backgroundColor: Colors.white,
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.black),
  );
}
