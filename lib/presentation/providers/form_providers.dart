import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/key_value_pair.dart';

// --- 1. CONFIGURACIÓN BÁSICA (URL y Método) ---

// El método HTTP seleccionado (GET, POST, etc.)
final selectedMethodProvider = StateProvider<String>((ref) => 'GET');

// La URL que escribe el usuario
final urlQueryProvider = StateProvider<String>((ref) => '');

// Lista estática de métodos soportados
final List<String> httpMethods = [
  'GET',
  'POST',
  'PUT',
  'PATCH',
  'DELETE',
  'HEAD',
  'OPTIONS',
];

// --- 2. LÓGICA DE TABLAS (Headers y Params) ---

/// Clase que maneja la lógica de añadir filas vacías automáticamente
class KeyValueNotifier extends StateNotifier<List<KeyValuePair>> {
  // Inicializamos con una fila vacía siempre
  KeyValueNotifier() : super([KeyValuePair()]);

  // Actualizar la "Clave"
  void updateKey(int index, String newKey) {
    // 1. Creamos una copia segura de la lista
    final newList = [...state];
    // 2. Modificamos el item específico
    newList[index] = newList[index].copyWith(key: newKey);
    // 3. Actualizamos el estado
    state = newList;
    // 4. Verificamos si necesitamos agregar una fila nueva al final
    _ensureEmptyRow();
  }

  // Actualizar el "Valor"
  void updateValue(int index, String newValue) {
    final newList = [...state];
    newList[index] = newList[index].copyWith(value: newValue);
    state = newList;
    _ensureEmptyRow();
  }

  // Eliminar una fila (Botón de basura)
  void removeRow(int index) {
    // Nunca dejamos la lista vacía, mínimo debe haber 1 row (aunque esté vacía)
    if (state.length > 1) {
      final newList = [...state];
      newList.removeAt(index);
      state = newList;
    } else {
      // Si es la única y la borran, solo la limpiamos
      state = [KeyValuePair()];
    }
  }

  // Lógica UX: Si la última fila ya tiene texto, agregamos una nueva vacía abajo
  void _ensureEmptyRow() {
    final lastItem = state.last;
    if (lastItem.key.isNotEmpty || lastItem.value.isNotEmpty) {
      state = [...state, KeyValuePair()];
    }
  }
}

// Provider independiente para HEADERS
final headersProvider =
    StateNotifierProvider<KeyValueNotifier, List<KeyValuePair>>((ref) {
      return KeyValueNotifier();
    });

// Provider independiente para QUERY PARAMS
// (Reutilizamos la misma lógica de clase, pero es una instancia separada en memoria)
final paramsProvider =
    StateNotifierProvider<KeyValueNotifier, List<KeyValuePair>>((ref) {
      return KeyValueNotifier();
    });

// --- 3. BODY DEL REQUEST ---

// Por ahora manejaremos el Body como un string crudo (Raw JSON)
final bodyContentProvider = StateProvider<String>((ref) => '');
