import 'package:flutter/material.dart';

Future<void> showErrorMessage(BuildContext context, String text) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        icon: Icon(Icons.error, color: Colors.red[600], size: 100),
        backgroundColor: Colors.red[200],
        title: const Text('Occoreu um erro'),
        content: SizedBox(
            height: 50,
            child: Center(
                child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ))),
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

Future<bool> showDeleteDialog(BuildContext context, String title, String text) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        icon: Icon(Icons.delete_outline_outlined,
            color: Colors.red[600], size: 100),
        backgroundColor: Colors.white,
        title: Text(title),
        content: SizedBox(
            height: 50,
            child: Center(
                child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ))),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Sim")),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancelar"))
        ],
      );
    },
  ).then((value) => value ?? false);
}
