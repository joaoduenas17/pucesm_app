import 'package:flutter/material.dart';

class CalificacionesScreen extends StatelessWidget {
  const CalificacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calificaciones')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(title: Text('Ingeniería de Software'), trailing: Text('8.7')),
          ListTile(title: Text('Bases de Datos'), trailing: Text('9.1')),
        ],
      ),
    );
  }
}
