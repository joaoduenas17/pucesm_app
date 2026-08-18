import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/study_programs.dart';
import '../models/user_profile.dart';
import 'preference_keys.dart';

class AppState extends ChangeNotifier {
  bool darkMode = false;
  double textScale = 1.0;
  bool reduceMotion = false;

  bool onboardingDone = false;
  String profileName = 'Estudiante PUCE';
  String profileEmail = 'correo@puce.edu.ec';
  StudyLevel studyLevel = StudyLevel.grado;
  String profileProgram = StudyPrograms.defaultFor(StudyLevel.grado);
  String? profileImagePath;

  UserProfile get userProfile => UserProfile(
    fullName: profileName,
    email: profileEmail,
    studyLevel: studyLevel,
    program: profileProgram,
  );

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    darkMode =
        prefs.getBool(PreferenceKeys.darkMode) ??
        prefs.getBool(PreferenceKeys.legacyDarkMode) ??
        false;
    textScale =
        (prefs.getDouble(PreferenceKeys.textScale) ??
                prefs.getDouble(PreferenceKeys.legacyTextScale) ??
                1.0)
            .clamp(0.9, 1.3)
            .toDouble();
    reduceMotion = prefs.getBool(PreferenceKeys.reduceMotion) ?? false;

    onboardingDone = prefs.getBool(PreferenceKeys.onboardingDone) ?? false;
    profileName =
        prefs.getString(PreferenceKeys.profileName) ??
        prefs.getString(PreferenceKeys.legacyFullName) ??
        profileName;
    profileEmail =
        prefs.getString(PreferenceKeys.profileEmail) ??
        prefs.getString(PreferenceKeys.legacyEmail) ??
        profileEmail;
    studyLevel = StudyLevelX.fromStorage(
      prefs.getString(PreferenceKeys.profileLevel),
    );
    profileProgram =
        prefs.getString(PreferenceKeys.profileProgram) ??
        prefs.getString(PreferenceKeys.legacyCareer) ??
        StudyPrograms.defaultFor(studyLevel);

    await _loadProfileImage(prefs);
    await _migrateLegacyPreferences(prefs);

    notifyListeners();
  }

  Future<void> _loadProfileImage(SharedPreferences prefs) async {
    final savedPath = prefs.getString(PreferenceKeys.profileImagePath);
    if (savedPath == null || savedPath.isEmpty) return;

    if (File(savedPath).existsSync()) {
      profileImagePath = savedPath;
      return;
    }

    profileImagePath = null;
    await prefs.remove(PreferenceKeys.profileImagePath);
  }

  Future<void> _migrateLegacyPreferences(SharedPreferences prefs) async {
    await prefs.setBool(PreferenceKeys.darkMode, darkMode);
    await prefs.setDouble(PreferenceKeys.textScale, textScale);

    if (!prefs.containsKey(PreferenceKeys.profileName)) {
      await prefs.setString(PreferenceKeys.profileName, profileName);
    }
    if (!prefs.containsKey(PreferenceKeys.profileEmail)) {
      await prefs.setString(PreferenceKeys.profileEmail, profileEmail);
    }
    if (!prefs.containsKey(PreferenceKeys.profileProgram)) {
      await prefs.setString(PreferenceKeys.profileProgram, profileProgram);
    }
    if (!prefs.containsKey(PreferenceKeys.profileLevel)) {
      await prefs.setString(
        PreferenceKeys.profileLevel,
        studyLevel.storageValue,
      );
    }

    for (final key in [
      PreferenceKeys.legacyDarkMode,
      PreferenceKeys.legacyTextScale,
      PreferenceKeys.legacyFullName,
      PreferenceKeys.legacyEmail,
      PreferenceKeys.legacyCareer,
      PreferenceKeys.legacyCampus,
    ]) {
      await prefs.remove(key);
    }
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PreferenceKeys.darkMode, value);
  }

  Future<void> setTextScale(double value) async {
    textScale = value.clamp(0.9, 1.3).toDouble();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(PreferenceKeys.textScale, textScale);
  }

  Future<void> setReduceMotion(bool value) async {
    reduceMotion = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PreferenceKeys.reduceMotion, value);
  }

  Future<void> setProfileImagePath(String? value) async {
    profileImagePath = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();

    if (value == null || value.isEmpty) {
      await prefs.remove(PreferenceKeys.profileImagePath);
    } else {
      await prefs.setString(PreferenceKeys.profileImagePath, value);
    }
  }

  Future<void> clearProfilePhoto() async {
    final path = profileImagePath;
    if (path != null) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } on FileSystemException {
        // La preferencia se limpia incluso si el archivo ya no es accesible.
      }
    }
    await setProfileImagePath(null);
  }

  Future<void> completeOnboarding({
    required String fullName,
    required String email,
    required StudyLevel level,
    required String program,
  }) async {
    await updateProfile(
      fullName: fullName,
      email: email,
      level: level,
      program: program,
    );

    onboardingDone = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PreferenceKeys.onboardingDone, true);
  }

  Future<void> updateProfile({
    required String fullName,
    required String email,
    required StudyLevel level,
    required String program,
  }) async {
    profileName = fullName.trim();
    profileEmail = email.trim();
    studyLevel = level;
    profileProgram = program.trim();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.profileName, profileName);
    await prefs.setString(PreferenceKeys.profileEmail, profileEmail);
    await prefs.setString(PreferenceKeys.profileLevel, studyLevel.storageValue);
    await prefs.setString(PreferenceKeys.profileProgram, profileProgram);
  }

  Future<void> resetProfileAndNotificationPreferences() async {
    await clearProfilePhoto();

    onboardingDone = false;
    profileName = 'Estudiante PUCE';
    profileEmail = 'correo@puce.edu.ec';
    studyLevel = StudyLevel.grado;
    profileProgram = StudyPrograms.defaultFor(studyLevel);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    for (final key in [
      PreferenceKeys.onboardingDone,
      PreferenceKeys.profileName,
      PreferenceKeys.profileEmail,
      PreferenceKeys.profileLevel,
      PreferenceKeys.profileProgram,
      PreferenceKeys.masterNotifications,
      PreferenceKeys.newsNotifications,
      PreferenceKeys.legacyNewsNotifications,
      PreferenceKeys.newsLastNotified,
      PreferenceKeys.calendarNotifications,
      PreferenceKeys.calendarOnlyMyLevel,
      PreferenceKeys.calendarIncludeInstitutional,
    ]) {
      await prefs.remove(key);
    }
  }
}
