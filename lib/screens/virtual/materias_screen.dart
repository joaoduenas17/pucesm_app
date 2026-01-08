import 'package:flutter/material.dart';

class MateriasScreen extends StatelessWidget {
  const MateriasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Materias')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _MateriaCard('Ingeniería de Software'),
          _MateriaCard('Bases de Datos'),
          _MateriaCard('Sistemas Distribuidos'),
        ],
      ),
    );
  }
}

class _MateriaCard extends StatelessWidget {
  final String nombre;
  const _MateriaCard(this.nombre);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.book),
        title: Text(nombre),
        subtitle: const Text('Ver contenido y actividades'),
      ),
    );
  }
}
