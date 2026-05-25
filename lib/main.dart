import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/premium_theme.dart';
import 'core/services/app_logger.dart';
import 'core/services/auth_secret_service.dart';
import 'core/services/security_profile_service.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/database_providers.dart';
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
    _migrateLegacyAuthSecrets();
  }

  Future<void> _checkColdStart() async {
    final service = ref.read(biometricServiceProvider);
    final enabled = await service.getBiometricEnabled();
    if (enabled && mounted) {
      ref.read(isAppLockedProvider.notifier).set(true);
    }
  }

  Future<void> _migrateLegacyAuthSecrets() async {
    final db = ref.read(databaseProvider);
    final authSecretService = ref.read(authSecretServiceProvider);
    final migrated = await authSecretService.migrateCollectionAuthData(db);
    if (migrated > 0) {
      AppLogger.info(
        'Migrated $migrated legacy auth secrets to secure storage',
      );
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
    final profileService = ref.read(securityProfileServiceProvider);
    final profile = await profileService.getProfile();
    final policy = profileService.policyFor(profile);

    if (state == AppLifecycleState.paused) {
      service.markAppBackgrounded();
    } else if (state == AppLifecycleState.resumed) {
      final isAppLocked = ref.read(isAppLockedProvider);
      if (!isAppLocked) {
        final shouldLock = policy.autoLockOnResume
            ? await service.shouldLockApp(
                forceDelaySeconds: policy.recommendedLockDelaySeconds,
              )
            : await service.shouldLockApp();
        if (shouldLock && mounted) {
          ref.read(isAppLockedProvider.notifier).set(true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar el color seleccionado por el usuario
    final primaryColorValue = ref.watch(themeColorProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isLocked = ref.watch(isAppLockedProvider);

    return MaterialApp(
      title: 'Xolo API Client',
      debugShowCheckedModeBanner: false,
      // Dynamic Theme based on persistence
      theme: XoloPremiumTheme.lightTheme(primaryColorValue),
      darkTheme: XoloPremiumTheme.darkTheme(primaryColorValue),
      themeMode: themeMode,
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
