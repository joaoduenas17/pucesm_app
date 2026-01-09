import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app_router.dart';
import 'app/app_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ FIX: inicializa datos de fechas para intl (meses/días en español)
  await initializeDateFormatting('es_EC', null);
  // (si quieres más genérico: await initializeDateFormatting();)

  final appState = AppState();
  await appState.load();

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

      // ✅ Locales (necesario para fechas/strings correctos)
      locale: const Locale('es', 'EC'),
      supportedLocales: const [
        Locale('es', 'EC'),
        Locale('es'),
        Locale('en'),
      ],
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

        return MediaQuery(
          data: fixed,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}