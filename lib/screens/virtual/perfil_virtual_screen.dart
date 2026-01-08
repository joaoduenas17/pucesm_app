import 'package:flutter/material.dart';

class PerfilVirtualScreen extends StatelessWidget {
  const PerfilVirtualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: Joao Dueñas'),
            SizedBox(height: 8),
            Text('Carrera: Ingeniería de Software'),
            SizedBox(height: 8),
            Text('Correo: joao@puce.edu.ec'),
          ],
        ),
      ),
    );
  }
}
