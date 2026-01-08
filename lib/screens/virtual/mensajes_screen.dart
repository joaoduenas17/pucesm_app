import 'package:flutter/material.dart';

class MensajesScreen extends StatelessWidget {
  const MensajesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes')),
      body: const Center(
        child: Text('No tienes mensajes nuevos'),
      ),
    );
  }
}
