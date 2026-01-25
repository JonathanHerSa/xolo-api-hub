import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/premium_theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // CONFIGURACIÓN PREMIUM: Edge-to-Edge (Contenido dibuja detrás de barras)
  // Requiere SafeAreas en las pantallas.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const ProviderScope(child: XoloApp()));
}

class XoloApp extends ConsumerWidget {
  const XoloApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchar el color seleccionado por el usuario
    final primaryColorValue = ref.watch(themeColorProvider);

    return MaterialApp(
      title: 'Xolo API Client',
      debugShowCheckedModeBanner: false,
      // Dynamic Theme based on persistence
      theme: XoloPremiumTheme.darkTheme(primaryColorValue),
      darkTheme: XoloPremiumTheme.darkTheme(primaryColorValue),
      themeMode: ThemeMode.dark, // Always Dark Premium
      home: const HomeScreen(),
    );
  }
}
