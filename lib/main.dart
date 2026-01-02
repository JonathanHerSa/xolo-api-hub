import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const XoloApp());
}

// 1. El Widget Raíz (Como tu App.vue)
class XoloApp extends StatelessWidget {
  const XoloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proyecto Xolo',
      theme: ThemeData.dark(), // Modo oscuro, obvio
      home: const UserFetcherScreen(),
    );
  }
}

// 2. Un Widget con Estado (StatefulWidget)
// Piensa en esto como un Componente de Vue.
class UserFetcherScreen extends StatefulWidget {
  const UserFetcherScreen({super.key});

  @override
  State<UserFetcherScreen> createState() => _UserFetcherScreenState();
}

// 3. La Lógica y la Vista (State + Template)
class _UserFetcherScreenState extends State<UserFetcherScreen> {
  // --- STATE (Tus variables reactivas "data()") ---
  String _userData = 'Esperando acción...';
  bool _isLoading = false;
  final Dio _dio = Dio(); // Instancia de Dio (Axios)

  // --- METHODS (Tus funciones "methods") ---
  Future<void> obtenerUsuario() async {
    // En Flutter, para actualizar la UI, DEBES envolver el cambio en setState()
    // Es como decirle a Vue: "Oye, esto cambió, re-renderiza".
    setState(() {
      _isLoading = true;
    });

    try {
      // La petición HTTP (Idéntico a JS async/await)
      final response = await _dio.get(
        'https://jsonplaceholder.typicode.com/users/1',
      );

      setState(() {
        _userData =
            "Usuario: ${response.data['name']}\nEmail: ${response.data['email']}";
      });
    } catch (e) {
      setState(() {
        _userData = 'Error al conectar: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- TEMPLATE (El método build devuelve el árbol de widgets) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consumo API con Dio')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Renderizado condicional (v-if / v-else)
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Text(
                  _userData,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),

              const SizedBox(height: 30), // Un margen (margin-top)

              ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : obtenerUsuario, // Deshabilita si carga
                icon: const Icon(Icons.download),
                label: const Text('Descargar Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
