import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // IMPORTANTE
import 'package:xolo/presentation/screens/home_screen.dart'; // Ya vamos a separar la pantalla

void main() {
  // Envolvemos la app en ProviderScope para que el estado fluya
  runApp(const ProviderScope(child: XoloApp()));
}

class XoloApp extends StatelessWidget {
  const XoloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xolo Client',
      theme: ThemeData.dark(useMaterial3: true),
      // Ya no llamamos a UserFetcherScreen aquí directo, mejor usa un archivo aparte
      home: const HomeScreen(),
    );
  }
}
