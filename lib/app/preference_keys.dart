abstract final class PreferenceKeys {
  static const onboardingDone = 'onboarding_done';

  static const darkMode = 'darkMode';
  static const textScale = 'textScale';
  static const reduceMotion = 'reduceMotion';

  static const profileName = 'profile_name';
  static const profileEmail = 'profile_email';
  static const profileLevel = 'profile_level';
  static const profileProgram = 'profile_program';
  static const profileImagePath = 'profileImagePath';

  static const masterNotifications = 'privacy_notifications';
  static const newsNotifications = 'notif_news_enabled';
  static const legacyNewsNotifications = 'notif_news';
  static const newsLastNotified = 'news_last_notified';
  static const calendarNotifications = 'notif_calendar_enabled';
  static const calendarOnlyMyLevel = 'notif_calendar_only_my_level';
  static const calendarIncludeInstitutional =
      'notif_calendar_include_institutional';

  // Claves usadas por versiones anteriores. Solo se leen para migrar datos.
  static const legacyDarkMode = 'dark_mode';
  static const legacyTextScale = 'text_scale';
  static const legacyFullName = 'fullName';
  static const legacyEmail = 'email';
  static const legacyCareer = 'career';
  static const legacyCampus = 'campus';
}
