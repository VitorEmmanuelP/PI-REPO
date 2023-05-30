import 'package:flutter/material.dart';
import 'package:pi/utils/styles.dart';

AppBar appBar(String text) {
  return AppBar(
    title: Text(
      text,
      style: const TextStyle(color: Colors.black),
    ),
    backgroundColor: scaffoldColor,
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.black),
  );
}
