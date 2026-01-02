import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_json_view/flutter_json_view.dart';

import '../../core/config/xolo_json_theme.dart';
import '../providers/request_provider.dart';
import '../providers/form_providers.dart';
import '../widgets/url_input_bar.dart';
import '../widgets/key_value_table.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestState = ref.watch(requestProvider);

    // DefaultTabController maneja el estado de las 3 pestañas automáticamente
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          title: const Text('Xolo Client'),
          backgroundColor: const Color(0xFF1E1E1E),
          elevation: 0,
          actions: [
            if (requestState.durationMs != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    "${requestState.durationMs} ms",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier',
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            // --- 1. INPUT DE URL ---
            const Padding(padding: EdgeInsets.all(12.0), child: UrlInputBar()),

            // --- 2. BARRA DE PESTAÑAS ---
            Container(
              height: 40,
              color: const Color(0xFF1E1E1E),
              child: const TabBar(
                indicatorColor: Colors.blueAccent,
                labelColor: Colors.blueAccent,
                unselectedLabelColor: Colors.white60,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                tabs: [
                  Tab(text: "PARAMS"),
                  Tab(text: "HEADERS"),
                  Tab(text: "BODY"),
                ],
              ),
            ),

            // --- 3. CONTENIDO DE PESTAÑAS (EDITABLES) ---
            Expanded(
              flex: 4, // 40% de la altura disponible
              child: TabBarView(
                children: [
                  // Tab Params
                  KeyValueTable(
                    provider: paramsProvider,
                    keyPlaceholder: "Query Param",
                    valuePlaceholder: "Value",
                  ),
                  // Tab Headers
                  KeyValueTable(
                    provider: headersProvider,
                    keyPlaceholder: "Header Key",
                    valuePlaceholder: "Value",
                  ),
                  // Tab Body
                  _buildBodyInput(ref),
                ],
              ),
            ),

            // Divisor visual
            const Divider(height: 1, thickness: 1, color: Colors.blueAccent),

            // --- 4. TÍTULO DE RESPUESTA ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: const Color(0xFF1E1E1E),
              child: const Text(
                "RESPONSE",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
            ),

            // --- 5. ÁREA DE RESPUESTA (VISUALIZADOR) ---
            Expanded(
              flex:
                  5, // 50% de la altura disponible (más grande para ver el JSON)
              child: Container(
                width: double.infinity,
                color: const Color(0xFF0D0D0D),
                child: _buildResponseArea(context, requestState),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Input simple para el Body (Texto Multilínea)
  Widget _buildBodyInput(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF181818),
      child: TextField(
        maxLines: null,
        expands: true,
        style: const TextStyle(fontFamily: 'Courier', color: Colors.white70),
        decoration: const InputDecoration(
          hintText: "{\n  \"key\": \"value\"\n}",
          hintStyle: TextStyle(color: Colors.white24),
          border: InputBorder.none,
        ),
        onChanged: (val) {
          ref.read(bodyContentProvider.notifier).state = val;
        },
      ),
    );
  }

  // Visualizador de respuesta (El que ya teníamos, integrado aquí)
  Widget _buildResponseArea(BuildContext context, RequestState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blueAccent),
      );
    }
    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            state.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }
    if (state.data == null) {
      return const Center(
        child: Icon(Icons.bolt, color: Colors.white12, size: 48),
      );
    }

    // Renderizamos Status + JSON
    return Column(
      children: [
        // Barra mini de status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          color: Colors.white.withOpacity(0.05),
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Status: ${state.statusCode}",
                style: TextStyle(
                  color:
                      (state.statusCode ?? 0) >= 200 &&
                          (state.statusCode ?? 0) < 300
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.copy, size: 14, color: Colors.white54),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: "Copiar JSON",
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: state.data.toString()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copiado!'),
                      duration: Duration(milliseconds: 500),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // El JSON View
        Expanded(
          child: state.data is Map || state.data is List
              ? JsonView.map(
                  state.data is List
                      ? {'array_result': state.data}
                      : state.data,
                  theme: xoloJsonTheme,
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(
                    state.data.toString(),
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      color: Colors.white70,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
