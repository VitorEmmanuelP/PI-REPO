import 'dart:io';

import 'package:flutter/material.dart';

class AnexoWidget extends StatelessWidget {
  final File? arquivo;

  const AnexoWidget({super.key, this.arquivo});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.file(
        arquivo!,
        width: MediaQuery.of(context).size.width / 2,
        height: MediaQuery.of(context).size.width / 2,
        fit: BoxFit.cover,
      ),
    );
  }
}
