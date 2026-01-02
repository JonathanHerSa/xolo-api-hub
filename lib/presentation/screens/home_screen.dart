import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/request_provider.dart';
import '../widgets/url_input_bar.dart'; // <--- Importante: Tu widget de la barra

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos los cambios en el request
    final requestState = ref.watch(requestProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fondo bien dark
      appBar: AppBar(
        title: const Text('Xolo Client'),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        actions: [
          // Un indicador chiquito de latencia si hubo respuesta
          if (requestState.durationMs != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  "${requestState.durationMs} ms",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // --- SECCIÓN SUPERIOR: INPUTS ---
          const Padding(padding: EdgeInsets.all(16.0), child: UrlInputBar()),

          const Divider(height: 1, color: Colors.white10),

          // --- SECCIÓN INFERIOR: RESULTADOS ---
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(
                0xFF0D0D0D,
              ), // Un negro un poco más profundo para la consola
              child: _buildResponseArea(requestState),
            ),
          ),
        ],
      ),
    );
  }

  // Método privado para limpiar el build y decidir qué mostrar
  Widget _buildResponseArea(RequestState state) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blueAccent),
            SizedBox(height: 16),
            Text(
              "Conectando con el inframundo...",
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
              if (state.statusCode != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Status Code: ${state.statusCode}",
                    style: const TextStyle(color: Colors.white38),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (state.data == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.code, color: Colors.white24, size: 64),
            SizedBox(height: 16),
            Text(
              "Listo para disparar",
              style: TextStyle(color: Colors.white24),
            ),
          ],
        ),
      );
    }

    // SI HAY DATOS:
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "STATUS: ${state.statusCode}",
                style: TextStyle(
                  color:
                      (state.statusCode ?? 0) >= 200 &&
                          (state.statusCode ?? 0) < 300
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SelectableText(
            state.data.toString(), // Aquí imprimimos el JSON crudo por ahora
            style: const TextStyle(
              fontFamily: 'Courier',
              color: Colors.lightBlueAccent,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
