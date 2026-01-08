import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app_router.dart';
import 'app/app_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = AppState();
  await appState.load(); // ✅ Carga preferencias (darkMode, textScale, reduceMotion)

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
