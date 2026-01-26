import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/premium_theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/biometric_lock_screen.dart';
import 'core/services/biometric_service.dart';

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

class XoloApp extends ConsumerStatefulWidget {
  const XoloApp({super.key});

  @override
  ConsumerState<XoloApp> createState() => _XoloAppState();
}

class _XoloAppState extends ConsumerState<XoloApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkColdStart();
  }

  Future<void> _checkColdStart() async {
    final service = ref.read(biometricServiceProvider);
    final enabled = await service.getBiometricEnabled();
    if (enabled && mounted) {
      ref.read(isAppLockedProvider.notifier).set(true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final service = ref.read(biometricServiceProvider);

    if (state == AppLifecycleState.paused) {
      service.markAppBackgrounded();
    } else if (state == AppLifecycleState.resumed) {
      final shouldLock = await service.shouldLockApp();
      if (shouldLock && mounted) {
        ref.read(isAppLockedProvider.notifier).set(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar el color seleccionado por el usuario
    final primaryColorValue = ref.watch(themeColorProvider);
    final isLocked = ref.watch(isAppLockedProvider);

    return MaterialApp(
      title: 'Xolo API Client',
      debugShowCheckedModeBanner: false,
      // Dynamic Theme based on persistence
      theme: XoloPremiumTheme.darkTheme(primaryColorValue),
      darkTheme: XoloPremiumTheme.darkTheme(primaryColorValue),
      themeMode: ThemeMode.dark, // Always Dark Premium
      home: const HomeScreen(),
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            if (isLocked) const BiometricLockScreen(),
          ],
        );
      },
    );
  }
}
