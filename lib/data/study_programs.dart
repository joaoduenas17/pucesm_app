import '../models/user_profile.dart';

abstract final class StudyPrograms {
  static const grado = <String>[
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

  static const posgrado = <String>[
    'Especialización en Salud y Seguridad Ocupacional',
    'Maestría en Derecho Constitucional',
    'Maestría en Derecho Penal',
    'Maestría en Geotecnia Aplicada',
    'Maestría en Hidráulica mención Gestión de Recursos Hídricos',
    'Maestría en Ingeniería Civil mención Estructuras Sismorresistentes',
    'Maestría en Innovación en Educación',
  ];

  static List<String> forLevel(StudyLevel level) {
    return level == StudyLevel.posgrado ? posgrado : grado;
  }

  static String defaultFor(StudyLevel level) => forLevel(level).first;
}
