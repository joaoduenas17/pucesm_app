import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum StudyLevel { grado, posgrado }

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  StudyLevel _level = StudyLevel.grado;
  String? _selectedProgram;

  // ✅ LISTA REAL (Grado) - basada en lo que me pasaste
  static const List<String> _gradoPrograms = [
    'Administración de Empresas',
    'Arquitectura',
    'Biología Marina',
    'Derecho',
    'Diseño Gráfico',
    'Enfermería',
    'Fisioterapia',
    'Ingeniería Civil',
    'Ingeniería en Alimentos',
    'Medicina',
    'Negocios Internacionales',
    'Nutrición y Dietética',
    'Psicología Clínica',
    'Software',
  ];

  // ✅ Posgrado: deja tu lista actual (luego me pasas la real y la cambiamos)
  static const List<String> _posgradoPrograms = [
    'Especialización en Salud y Seguridad Ocupacional',
    'Maestría en Derecho Constitucional',
    'Maestría en Derecho Penal',
    'Maestría en Geotecnia Aplicada',
    'Maestría en Hidráulica mención Gestión de Recursos Hídricos',
    'Maestría en Ingeniería Civil mención Estructuras Sismorresistentes',
    'Maestría en Innovación en Educación'
  ];

  List<String> get _currentPrograms =>
      _level == StudyLevel.grado ? _gradoPrograms : _posgradoPrograms;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    _nameCtrl.text = prefs.getString('profile_name') ?? 'Estudiante PUCE';
    _emailCtrl.text = prefs.getString('profile_email') ?? 'correo@puce.edu.ec';

    final levelStr = prefs.getString('profile_level') ?? 'grado';
    _level = levelStr == 'posgrado' ? StudyLevel.posgrado : StudyLevel.grado;

    final savedProgram = prefs.getString('profile_program');
    final programs = _currentPrograms;

    if (savedProgram != null && programs.contains(savedProgram)) {
      _selectedProgram = savedProgram;
    } else {
      _selectedProgram = programs.isNotEmpty ? programs.first : null;
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (_selectedProgram == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona tu carrera/programa.')),
      );
      return;
    }

    setState(() => _saving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', _nameCtrl.text.trim());
    await prefs.setString('profile_email', _emailCtrl.text.trim());
    await prefs.setString(
      'profile_level',
      _level == StudyLevel.grado ? 'grado' : 'posgrado',
    );
    await prefs.setString('profile_program', _selectedProgram!);

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context, true); // ✅ para que Profile pueda refrescar
  }

  void _onLevelChanged(StudyLevel? value) {
    if (value == null) return;

    setState(() {
      _level = value;

      final list = _currentPrograms;
      if (_selectedProgram == null || !list.contains(_selectedProgram)) {
        _selectedProgram = list.isNotEmpty ? list.first : null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4FA),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    'Configura tus preferencias para personalizar el contenido mostrado en la aplicación.',
                    style: TextStyle(color: Color(0xFF5B6472), height: 1.25),
                  ),
                ),
                const SizedBox(height: 14),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Nombre completo',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) {
                          final t = (v ?? '').trim();
                          if (t.isEmpty) return 'Ingresa un nombre';
                          if (t.length < 3) return 'Nombre demasiado corto';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Correo',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          final t = (v ?? '').trim();
                          if (t.isEmpty) return 'Ingresa un correo';
                          if (!t.contains('@')) return 'Correo no válido';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      const _BlockTitle(title: 'Nivel'),
                      const SizedBox(height: 10),

                      _LevelSelector(
                        value: _level,
                        onChanged: _onLevelChanged,
                      ),

                      const SizedBox(height: 16),

                      _BlockTitle(
                        title: _level == StudyLevel.grado
                            ? 'Carrera (Grado)'
                            : 'Programa (Posgrado)',
                      ),
                      const SizedBox(height: 10),

                      // ✅ FIX OVERFLOW: isExpanded + selectedItemBuilder
                      DropdownButtonFormField<String>(
                        value: _selectedProgram,
                        isExpanded: true, // ✅ CLAVE para que no se desborde
                        items: _currentPrograms
                            .map(
                              (p) => DropdownMenuItem<String>(
                                value: p,
                                child: Text(
                                  p,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        selectedItemBuilder: (context) {
                          return _currentPrograms.map((p) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                p,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList();
                        },
                        onChanged: (v) => setState(() => _selectedProgram = v),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.school_outlined),
                          labelText: 'Seleccionar',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Selecciona una opción';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: _saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(_saving ? 'Guardando...' : 'Guardar cambios'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _BlockTitle extends StatelessWidget {
  final String title;
  const _BlockTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: cs.primary.withOpacity(0.9),
        ),
      ),
    );
  }
}

class _LevelSelector extends StatelessWidget {
  final StudyLevel value;
  final ValueChanged<StudyLevel?> onChanged;

  const _LevelSelector({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget pill({
      required String label,
      required StudyLevel v,
      required IconData icon,
    }) {
      final active = value == v;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onChanged(v),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: active ? cs.primary.withOpacity(0.14) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: active ? cs.primary.withOpacity(0.45) : const Color(0x1A000000),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: active ? cs.primary : const Color(0xFF5B6472)),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: active ? cs.primary : const Color(0xFF5B6472),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        pill(label: 'Grado', v: StudyLevel.grado, icon: Icons.school_outlined),
        const SizedBox(width: 10),
        pill(
          label: 'Posgrado',
          v: StudyLevel.posgrado,
          icon: Icons.workspace_premium_outlined,
        ),
      ],
    );
  }
}
