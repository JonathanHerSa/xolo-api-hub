import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// 1. Importamos la Entidad (El modelo de datos)
import '../../domain/entities/key_value_pair.dart';

// 2. IMPORTANTE: Importamos donde definiste la clase KeyValueNotifier
import '../providers/form_providers.dart';

class KeyValueTable extends ConsumerWidget {
  // Definimos que este widget recibe un Provider específico de tipo KeyValueNotifier
  final StateNotifierProvider<KeyValueNotifier, List<KeyValuePair>> provider;
  final String keyPlaceholder;
  final String valuePlaceholder;

  const KeyValueTable({
    super.key,
    required this.provider,
    this.keyPlaceholder = "Key",
    this.valuePlaceholder = "Value",
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos la lista de filas (Headers o Params)
    final rows = ref.watch(provider);

    // Obtenemos el controlador para ejecutar funciones (add/remove/update)
    final notifier = ref.read(provider.notifier);

    return ListView.separated(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 60,
      ), // Espacio para que no lo tape el teclado
      itemCount: rows.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Colors.white10),
      itemBuilder: (context, index) {
        final item = rows[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- COLUMNA KEY ---
              Expanded(
                flex: 4,
                child: TextFormField(
                  // Truco sucio para el MVP: Usamos un controller desechable inicializado con el valor.
                  // (Nota: En producción idealmente se usan controllers persistentes, pero esto funciona)
                  controller: TextEditingController(text: item.key)
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: item.key.length),
                    ),
                  decoration: InputDecoration(
                    hintText: keyPlaceholder,
                    hintStyle: const TextStyle(
                      color: Colors.white24,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: const TextStyle(
                    color: Colors.lightBlueAccent,
                    fontFamily: 'Courier',
                    fontSize: 14,
                  ),
                  onChanged: (val) => notifier.updateKey(index, val),
                ),
              ),

              // Divisor vertical sutil
              Container(
                width: 1,
                height: 20,
                color: Colors.white12,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),

              // --- COLUMNA VALUE ---
              Expanded(
                flex: 5,
                child: TextFormField(
                  controller: TextEditingController(text: item.value)
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: item.value.length),
                    ),
                  decoration: InputDecoration(
                    hintText: valuePlaceholder,
                    hintStyle: const TextStyle(
                      color: Colors.white24,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontFamily: 'Courier',
                    fontSize: 14,
                  ),
                  onChanged: (val) => notifier.updateValue(index, val),
                ),
              ),

              // --- BOTÓN ELIMINAR ---
              // Solo mostramos el botón de borrar si NO es la última fila vacía
              // (Para que siempre haya una fila disponible para escribir)
              if (index != rows.length - 1)
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white30,
                  ),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                  onPressed: () => notifier.removeRow(index),
                )
              else
                // Espaciador invisible para mantener alineación
                const SizedBox(width: 32),
            ],
          ),
        );
      },
    );
  }
}
