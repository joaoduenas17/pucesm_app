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

  static const pucetec = <String>[
    'Tecnología Superior en Acuicultura',
    'Tecnología Superior en Marketing Digital',
    'Tecnología Superior Universitaria en Gastronomía',
  ];

  static List<String> forLevel(StudyLevel level) {
    switch (level) {
      case StudyLevel.grado:
        return grado;
      case StudyLevel.posgrado:
        return posgrado;
      case StudyLevel.pucetec:
        return pucetec;
    }
  }

  static String defaultFor(StudyLevel level) => forLevel(level).first;
}
