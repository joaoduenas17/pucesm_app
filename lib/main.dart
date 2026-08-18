import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'app/app_router.dart';
import 'app/app_state.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';
import 'utils/metric_logger.dart';

Future<void> main() async {
  MetricLogger.marcarInicioApp();
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Timezones (necesario para programar notificaciones con hora exacta)
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Guayaquil'));

  // La app sigue disponible aunque el servicio nativo no pueda inicializarse.
  try {
    await NotificationService.init();
  } catch (error, stackTrace) {
    debugPrint('No se pudieron inicializar las notificaciones: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  // ✅ Intl para meses/días en español (Calendar)
  await initializeDateFormatting('es_EC', null);

  final appState = AppState();
  await appState.load();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    MetricLogger.registrarDesdeInicio('inicio_dart_primer_frame');
  });

  runApp(
    ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,

      // ✅ Locales
      locale: const Locale('es', 'EC'),
      supportedLocales: const [Locale('es', 'EC'), Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ✅ Temas
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: state.darkMode ? ThemeMode.dark : ThemeMode.light,

      // ✅ Accesibilidad global
      builder: (context, child) {
        final mq = MediaQuery.of(context);

        final fixed = mq.copyWith(
          textScaler: TextScaler.linear(state.textScale),
          disableAnimations: state.reduceMotion,
        );

        return MediaQuery(data: fixed, child: child ?? const SizedBox.shrink());
      },
    );
  }
}
