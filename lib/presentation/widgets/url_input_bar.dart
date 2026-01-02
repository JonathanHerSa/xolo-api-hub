import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Imports necesarios para leer todos los datos
import '../providers/form_providers.dart';
import '../providers/request_provider.dart';

class UrlInputBar extends ConsumerWidget {
  const UrlInputBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Escuchamos valores básicos
    final selectedMethod = ref.watch(selectedMethodProvider);
    final requestState = ref.watch(requestProvider);

    // Función auxiliar para color del método
    Color getMethodColor(String method) {
      switch (method) {
        case 'GET':
          return Colors.blueAccent;
        case 'POST':
          return Colors.greenAccent;
        case 'DELETE':
          return Colors.redAccent;
        case 'PUT':
          return Colors.orangeAccent;
        case 'PATCH':
          return Colors.purpleAccent;
        default:
          return Colors.grey;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // A. DROPDOWN DE MÉTODO
          DropdownButton<String>(
            value: selectedMethod,
            dropdownColor: const Color(0xFF2C2C2C),
            underline: const SizedBox(),
            style: TextStyle(
              color: getMethodColor(selectedMethod),
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
            items: httpMethods.map((method) {
              return DropdownMenuItem(value: method, child: Text(method));
            }).toList(),
            onChanged: (value) {
              if (value != null)
                ref.read(selectedMethodProvider.notifier).state = value;
            },
          ),

          Container(
            width: 1,
            height: 24,
            color: Colors.white24,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),

          // B. INPUT DE URL
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'https://api.ejemplo.com',
                hintStyle: TextStyle(color: Colors.white24),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(
                fontFamily: 'Courier',
                color: Colors.white,
              ),
              onChanged: (value) {
                ref.read(urlQueryProvider.notifier).state = value;
              },
            ),
          ),

          // C. BOTÓN SEND (Aquí está la magia)
          IconButton(
            icon: requestState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.blueAccent,
                    ),
                  )
                : const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: requestState.isLoading
                ? null
                : () {
                    // 1. Recopilar Datos
                    final method = ref.read(selectedMethodProvider);
                    final url = ref.read(urlQueryProvider);
                    final paramsList = ref.read(paramsProvider);
                    final headersList = ref.read(headersProvider);
                    final rawBody = ref.read(bodyContentProvider);

                    // 2. Transformar Listas a Mapas (ignorando vacíos o inactivos)
                    final Map<String, dynamic> paramsMap = {};
                    for (var item in paramsList) {
                      if (item.key.isNotEmpty && item.isActive) {
                        paramsMap[item.key] = item.value;
                      }
                    }

                    final Map<String, dynamic> headersMap = {};
                    for (var item in headersList) {
                      if (item.key.isNotEmpty && item.isActive) {
                        headersMap[item.key] = item.value;
                      }
                    }

                    // 3. Disparar Request
                    ref
                        .read(requestProvider.notifier)
                        .fetchData(
                          method: method,
                          url: url,
                          queryParams: paramsMap,
                          headers: headersMap,
                          body: rawBody.isNotEmpty ? rawBody : null,
                        );
                  },
          ),
        ],
      ),
    );
  }
}
