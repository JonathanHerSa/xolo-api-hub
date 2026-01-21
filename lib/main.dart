import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/xolo_theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: XoloApp()));
}

class XoloApp extends ConsumerWidget {
  const XoloApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Xolo',
      debugShowCheckedModeBanner: false,
      theme: XoloTheme.lightTheme,
      darkTheme: XoloTheme.darkTheme,
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}
