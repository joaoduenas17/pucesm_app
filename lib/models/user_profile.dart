enum StudyLevel { grado, posgrado }

extension StudyLevelX on StudyLevel {
  String get storageValue => name;

  String get label => this == StudyLevel.posgrado ? 'Posgrado' : 'Grado';

  static StudyLevel fromStorage(String? value) {
    return value?.toLowerCase() == StudyLevel.posgrado.name
        ? StudyLevel.posgrado
        : StudyLevel.grado;
  }
}

class UserProfile {
  final String fullName;
  final String email;
  final StudyLevel studyLevel;
  final String program;

  const UserProfile({
    required this.fullName,
    required this.email,
    required this.studyLevel,
    required this.program,
  });
}
