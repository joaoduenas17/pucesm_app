📱 PUCESM App – Aplicación Académica PUCE Manabí

Aplicación móvil desarrollada en Flutter como proyecto académico, cuyo objetivo es centralizar información institucional relevante de la PUCE Manabí, ofreciendo una experiencia moderna, personalizada y accesible para estudiantes de grado y posgrado.

🎯 Objetivo del proyecto

Desarrollar una aplicación móvil multiplataforma que permita a los estudiantes:

Consultar noticias institucionales

Visualizar el calendario académico

Acceder a carreras y programas

Gestionar preferencias personales

Recibir notificaciones personalizadas según su nivel académico

El proyecto se enfoca en la experiencia de usuario, la organización del código y la justificación académica, simulando escenarios reales usados en aplicaciones institucionales.

🧩 Funcionalidades principales
👤 Perfil de usuario

Edición de nombre y correo

Selección de nivel académico: Grado / Posgrado

Selección de carrera o programa

Persistencia local mediante SharedPreferences

Foto de perfil (galería / cámara)

📰 Noticias institucionales

Consumo de API pública institucional

Listado de noticias con imágenes

Vista detallada con contenido HTML

Visualización embebida mediante WebView

Opción de abrir la noticia en el sitio web oficial

Notificación automática cuando hay una noticia nueva

📅 Calendario académico

Eventos académicos reales (grado, posgrado, institucional)

Filtros por categoría

Búsqueda de eventos

Agrupación por mes

Detalle del evento

Agregar evento al calendario del dispositivo

Recordatorios personalizados según el nivel académico

🔔 Sistema de notificaciones

Notificaciones locales con flutter_local_notifications

Filtros por:

Nivel académico

Preferencias del usuario

Configuración desde la pantalla de Privacidad y Seguridad

⚠️ Nota: En algunos emuladores Android las notificaciones programadas pueden no ejecutarse correctamente. En dispositivos físicos el sistema funciona según lo esperado.

🆘 Centro de ayuda

Preguntas frecuentes

Contacto institucional (correo y teléfono)

Enlaces oficiales

🛠️ Tecnologías utilizadas

Flutter 3

Dart

go_router – navegación

provider – manejo de estado

shared_preferences – persistencia local

http – consumo de API REST

flutter_local_notifications – notificaciones

timezone – programación de recordatorios

add_2_calendar – integración con calendario del dispositivo

webview_flutter – visualización de contenido HTML

image_picker – selección de imágenes

🧠 Arquitectura del proyecto

El proyecto sigue una estructura modular:
lib/
├── app/
│   └── app_state.dart
├── models/
│   ├── news_item.dart
│   └── course_item.dart
├── services/
│   ├── pucem_api.dart
│   └── notification_service.dart
├── screens/
│   ├── home/
│   ├── news/
│   ├── calendar/
│   ├── profile/
│   ├── courses/
│   └── help/
├── widgets/
└── main.dart

Esta separación facilita:

Mantenimiento

Escalabilidad

Justificación académica del diseño

🌐 Backend y datos

El proyecto consume APIs públicas institucionales

No se implementa backend propio

Se simula un entorno real mediante:

APIs REST

Persistencia local

Lógica de negocio en el cliente

Esto permite justificar el proyecto como un prototipo funcional (MVP).

🚀 Instalación y ejecución

Clonar el repositorio:

git clone https://github.com/tu-usuario/pucesm_app.git


Instalar dependencias:

flutter pub get


Ejecutar la aplicación:

flutter run


Recomendado probar en dispositivo físico para notificaciones.

📌 Estado del proyecto

✅ MVP funcional
✅ Listo para presentación académica
✅ Código organizado y documentado
🔜 Posible integración futura con backend real

👨‍💻 Autor

Joao Dueñas
Proyecto académico – Ingeniería de Software
Pontificia Universidad Católica del Ecuador – Sede Manabí

📄 Licencia

Proyecto desarrollado con fines académicos y educativos.
No destinado a uso comercial.