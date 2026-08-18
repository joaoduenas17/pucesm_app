# Pruebas técnicas para la tesis

La instrumentación de rendimiento está desactivada en la aplicación normal. Se
habilita únicamente mediante `--dart-define=THESIS_METRICS=true` y escribe líneas
identificadas con `[TESIS_METRICA]` en el registro de Flutter.

## Métricas

| Métrica | Alcance |
| --- | --- |
| `inicio_dart_primer_frame` | Desde la entrada a `main()` hasta el primer frame de Flutter. Incluye las inicializaciones hechas en Dart, pero no el tiempo nativo anterior al arranque del motor. |
| `inicio_dart_home` | Desde la entrada a `main()` hasta el primer frame de Inicio. Incluye el splash intencional de 1,3 segundos. Solo es comparable cuando el onboarding ya está completado. |
| `carga_noticias_inicio` | Solicitud, respuesta y parseo de las noticias mostradas al entrar a Inicio. |
| `carga_grado_inicio` | Solicitud, respuesta y parseo de los programas de grado mostrados al entrar a Inicio. |
| `carga_posgrado_inicio` | Solicitud, respuesta y parseo de los programas de posgrado mostrados al entrar a Inicio. |
| `recarga_noticias` | Actualización manual de noticias. |
| `recarga_grado` | Actualización manual de programas de grado. |
| `recarga_posgrado` | Actualización manual de programas de posgrado. |

Las tres cargas iniciales se ejecutan concurrentemente. Sus tiempos se analizan
por separado y no deben sumarse.

## Matriz de prueba

Realizar tres repeticiones por dispositivo:

| Dispositivo | Android | RAM | Resolución |
| --- | ---: | ---: | ---: |
| Pixel 8 | 14 | 8 GB | 1080 × 2400 |
| Pixel 6 | 13 | 6 GB | 1080 × 2400 |
| Pixel 4 | 12 | 4 GB | 1080 × 2280 |

## Preparación

1. Utilizar la misma conexión de red en todas las pruebas.
2. Completar el onboarding antes de iniciar las mediciones.
3. Ejecutar en modo `profile`; no medir después de un hot reload.
4. Forzar el cierre de la aplicación antes de cada medición de inicio.
5. Mantener iguales los datos y preferencias entre las tres repeticiones.

## Ejecución en PowerShell

Reemplazar el identificador de dispositivo, la etiqueta y la repetición:

```powershell
flutter run --profile -d <device-id> `
  --dart-define=THESIS_METRICS=true `
  --dart-define=THESIS_DEVICE=pixel8_android14 `
  --dart-define=THESIS_RUN=1
```

En una segunda terminal se pueden guardar únicamente las métricas:

```powershell
flutter logs -d <device-id> |
  Select-String "TESIS_METRICA" |
  Tee-Object -FilePath metricas_pixel8_r1.txt
```

Ejemplo de salida:

```text
[TESIS_METRICA] dispositivo=pixel8_android14 repeticion=1 metrica=carga_noticias_inicio duracion_ms=428.317 estado=ok
```

Para la siguiente repetición, cerrar completamente la aplicación, cambiar
`THESIS_RUN` a `2` o `3` y repetir el procedimiento. Conservar los tres valores
individuales de cada métrica y calcular el resumen estadístico usando el mismo
criterio aplicado en el documento de tesis.
