import 'package:flutter/material.dart';

class AgendaView extends StatefulWidget {
  const AgendaView({super.key});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OutlinedButton(
        onPressed: () {
          
        },
        child: const Text('AQUi'),
      ),
    );
  }
}
