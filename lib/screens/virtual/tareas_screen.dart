import 'package:flutter/material.dart';

class TareasScreen extends StatelessWidget {
  const TareasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tareas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.assignment),
            title: Text('Proyecto Final'),
            subtitle: Text('Entrega: 20 de enero'),
          ),
          ListTile(
            leading: Icon(Icons.assignment),
            title: Text('Examen Parcial'),
            subtitle: Text('Disponible'),
          ),
        ],
      ),
    );
  }
}
