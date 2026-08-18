# PUCE Manabí App

[![Flutter CI](https://github.com/joaoduenas17/pucesm_app/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/joaoduenas17/pucesm_app/actions/workflows/flutter-ci.yml)

Aplicación académica desarrollada en Flutter para centralizar información útil de PUCE Manabí. Es un proyecto académico independiente y no una aplicación oficial de la Universidad.

## Funcionalidades

- Noticias institucionales obtenidas desde la API pública, con actualización manual y detalle en HTML.
- Oferta vigente de carreras de grado, programas de posgrado y PUCE TEC.
- Calendario académico 2026 con vistas de agenda y mes, eventos personales, búsqueda, filtros, exportación al calendario del dispositivo y recordatorios locales.
- Acceso integrado al Entorno Virtual de Aprendizaje (EVA).
- Perfil local con nivel, programa y foto.
- Tema claro/oscuro, tamaño de texto y reducción de animaciones.
- Preferencias de notificación explícitas y persistidas en el dispositivo.

La aplicación no requiere un backend propio: consume los servicios públicos institucionales existentes y mantiene las preferencias personales de forma local.

## Plataformas

El desarrollo y las pruebas se concentran en Android. La configuración básica de iOS, macOS, Windows y Linux se conserva, pero las integraciones nativas deben validarse en cada plataforma antes de distribuirlas.

## Requisitos

- Flutter `3.47.0` estable, compatible con Dart `^3.10.4`.
- Android Studio o un dispositivo Android configurado para depuración.
- Conexión a Internet para noticias, programas y EVA.

## Ejecución

```bash
git clone https://github.com/joaoduenas17/pucesm_app.git
cd pucesm_app
flutter pub get
flutter run
```

Comprobaciones recomendadas antes de integrar cambios:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

## Integración continua

GitHub Actions ejecuta automáticamente esas cuatro comprobaciones en cada pull request dirigido a `main` y después de cada actualización de la rama principal. Flutter y Java están fijados a versiones conocidas para que las validaciones sean reproducibles.

## Estructura

```text
lib/
├── app/          # Estado, navegación y claves de preferencias
├── data/         # Catálogos locales compartidos
├── models/       # Modelos de perfil, noticias y programas
├── screens/      # Pantallas organizadas por funcionalidad
├── services/     # API institucional y notificaciones locales
├── theme/        # Temas claro y oscuro
└── widgets/      # Componentes compartidos
```

## Firma de Android

Las compilaciones locales pueden usar la firma de depuración. Para crear un artefacto distribuible:

1. Genera un keystore de carga y guárdalo como `android/app/upload-keystore.jks`.
2. Copia `android/key.properties.example` a `android/key.properties`.
3. Reemplaza los valores de ejemplo con tus credenciales.
4. Ejecuta `flutter build appbundle --release`.

El keystore y `key.properties` están excluidos de Git y nunca deben publicarse.

## Datos y privacidad

- Nombre, correo, programa, foto y preferencias se guardan únicamente en el dispositivo.
- Los permisos de notificación se solicitan al activar la función o al ejecutar una prueba.
- Las fechas académicas pueden cambiar; siempre prevalecen las publicaciones oficiales de la Universidad.

## Pruebas técnicas de tesis

La instrumentación de rendimiento se mantiene desactivada en la aplicación
normal. El protocolo reproducible, las métricas y los comandos para habilitarla
están documentados en [docs/pruebas_tecnicas_tesis.md](docs/pruebas_tecnicas_tesis.md).

## Autor

Joao Dueñas — proyecto académico de Ingeniería de Software, Pontificia Universidad Católica del Ecuador, Sede Manabí.
