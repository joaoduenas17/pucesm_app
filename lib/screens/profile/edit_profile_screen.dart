import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _name;
  late TextEditingController _email;
  late TextEditingController _career;
  late TextEditingController _campus;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();

    _name = TextEditingController(text: state.fullName);
    _email = TextEditingController(text: state.email);
    _career = TextEditingController(text: state.career);
    _campus = TextEditingController(text: state.campus);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _career.dispose();
    _campus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<AppState>().updateProfile(
          fullName: _name.text,
          email: _email.text,
          career: _career.text,
          campus: _campus.text,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado ✅')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
              validator: (v) => (v == null || v.trim().length < 3)
                  ? 'Ingresa un nombre válido'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Correo'),
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return 'Ingresa tu correo';
                if (!s.contains('@')) return 'Correo no válido';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _career,
              decoration: const InputDecoration(labelText: 'Carrera'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Ingresa tu carrera'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _campus,
              decoration: const InputDecoration(labelText: 'Campus / Sede'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Ingresa tu sede'
                  : null,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
