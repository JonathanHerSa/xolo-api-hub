import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/form_providers.dart';
import '../providers/request_provider.dart'; // Importa el notifier que hicimos antes

class UrlInputBar extends ConsumerWidget {
  const UrlInputBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos los valores
    final selectedMethod = ref.watch(selectedMethodProvider);
    final requestState = ref.watch(requestProvider);

    // Colores según el método (Un toque pro de UX)
    Color getMethodColor(String method) {
      switch (method) {
        case 'GET':
          return Colors.blue;
        case 'POST':
          return Colors.green;
        case 'DELETE':
          return Colors.red;
        case 'PUT':
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900], // Fondo oscuro para la barra
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 1. EL DROPDOWN (Método)
          DropdownButton<String>(
            value: selectedMethod,
            underline: const SizedBox(), // Quitamos la línea fea por defecto
            style: TextStyle(
              color: getMethodColor(selectedMethod),
              fontWeight: FontWeight.bold,
            ),
            items: httpMethods.map((method) {
              return DropdownMenuItem(value: method, child: Text(method));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                // Actualizamos el provider
                ref.read(selectedMethodProvider.notifier).state = value;
              }
            },
          ),

          const VerticalDivider(color: Colors.white24, width: 20),

          // 2. EL INPUT (URL)
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'https://api.ejemplo.com',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(
                fontFamily: 'Courier',
              ), // Monospace para URLs
              onChanged: (value) {
                // Actualizamos el provider de la URL
                ref.read(urlQueryProvider.notifier).state = value;
              },
            ),
          ),

          // 3. EL BOTÓN (Send)
          IconButton(
            icon: requestState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: requestState.isLoading
                ? null // Deshabilitado si carga
                : () {
                    // Leemos los valores actuales de los providers
                    final method = ref.read(selectedMethodProvider);
                    final url = ref.read(urlQueryProvider);

                    // Ejecutamos la lógica del negocio
                    ref
                        .read(requestProvider.notifier)
                        .fetchData(method: method, url: url);
                  },
          ),
        ],
      ),
    );
  }
}
