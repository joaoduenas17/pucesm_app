enum StudyLevel { grado, posgrado, pucetec }

extension StudyLevelX on StudyLevel {
  String get storageValue => name;

  String get label {
    switch (this) {
      case StudyLevel.grado:
        return 'Grado';
      case StudyLevel.posgrado:
        return 'Posgrado';
      case StudyLevel.pucetec:
        return 'PUCE TEC';
    }
  }

  static StudyLevel fromStorage(String? value) {
    final normalized = value?.trim().toLowerCase();
    return StudyLevel.values.firstWhere(
      (level) => level.name == normalized,
      orElse: () => StudyLevel.grado,
    );
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
