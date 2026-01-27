import 'package:flutter/foundation.dart';

/// 1) Producción (Render/Railway): cambia luego por tu URL real.
/// Ej: https://pucesm-backend.onrender.com
const String PROD_API_BASE = 'https://api.pucesm.edu.ec';

/// 2) Local para Android emulator:
/// - Android emulator usa 10.0.2.2 en vez de localhost.
/// - iOS simulator sí usa localhost (pero en tu caso estás en Windows/Android).
const String ANDROID_EMULATOR_BASE = 'http://10.0.2.2:3000';

/// 3) Local para teléfono real en tu WiFi:
/// Cambia esto por tu IP actual cuando pruebes en físico.
/// Ej: http://192.168.1.50:3000
const String PHONE_LAN_BASE = 'http://192.168.0.50:3000';

/// Flag rápido para elegir backend.
/// - true  => usa backend local (dev)
/// - false => usa producción
const bool USE_LOCAL_BACKEND = true;

/// Base final
String apiBase() {
  if (!USE_LOCAL_BACKEND) return PROD_API_BASE;

  // En debug normalmente estás en emulador: 10.0.2.2
  // Si estás en teléfono real, cambia a PHONE_LAN_BASE.
  // Para hacerlo automático al 100% necesitaríamos platform checks,
  // pero esto ya es práctico y estable para tesis.
  return ANDROID_EMULATOR_BASE;
}
