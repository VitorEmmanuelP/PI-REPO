import 'package:flutter/material.dart';

Future<void> showErrorMessage(BuildContext context, String text) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Occoreu um erro'),
        content: Text(text),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Ok"))
        ],
      );
    },
  );
}
