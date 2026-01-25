import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/key_value_pair.dart';

// --- 1. CONFIGURACIÓN BÁSICA (URL y Método) ---

// Migrando StateProvider a Notifier para compatibilidad total
class SelectedMethodNotifier extends Notifier<String> {
  @override
  String build() => 'GET';

  void set(String value) => state = value;
}

final selectedMethodProvider = NotifierProvider<SelectedMethodNotifier, String>(
  SelectedMethodNotifier.new,
);

class UrlQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final urlQueryProvider = NotifierProvider<UrlQueryNotifier, String>(
  UrlQueryNotifier.new,
);

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

/// Clase BASE para headers y params.
/// Para reutilizar lógica, usaremos mixin o abstract class?
/// Notifier funciona por tipo. Si uso la misma clase para dos providers, es independiente.
class KeyValueNotifier extends Notifier<List<KeyValuePair>> {
  @override
  List<KeyValuePair> build() {
    return [KeyValuePair()];
  }

  void updateKey(int index, String newKey) {
    final newList = [...state];
    newList[index] = newList[index].copyWith(key: newKey);
    state = newList;
    _ensureEmptyRow();
  }

  void updateValue(int index, String newValue) {
    final newList = [...state];
    newList[index] = newList[index].copyWith(value: newValue);
    state = newList;
    _ensureEmptyRow();
  }

  void updateList(List<KeyValuePair> newList) {
    if (newList.isEmpty) {
      state = [KeyValuePair()];
    } else {
      state = [...newList];
      _ensureEmptyRow();
    }
  }

  void removeRow(int index) {
    if (state.length > 1) {
      final newList = [...state];
      newList.removeAt(index);
      state = newList;
    } else {
      state = [KeyValuePair()];
    }
  }

  void _ensureEmptyRow() {
    if (state.isEmpty) {
      state = [KeyValuePair()];
      return;
    }
    final lastItem = state.last;
    if (lastItem.key.isNotEmpty || lastItem.value.isNotEmpty) {
      state = [...state, KeyValuePair()];
    }
  }
}

// Necesitamos subclases distintas si queremos definirlos por tipo?
// No, NotifierProvider(Class.new) crea instancias distintas.
// Pero para tipar KeyValueTable...
// Definamos el tipo Providers.

final headersProvider = NotifierProvider<HeadersNotifier, List<KeyValuePair>>(
  HeadersNotifier.new,
);

class HeadersNotifier extends KeyValueNotifier {}

final paramsProvider = NotifierProvider<ParamsNotifier, List<KeyValuePair>>(
  ParamsNotifier.new,
);

class ParamsNotifier extends KeyValueNotifier {}

// --- 3. BODY DEL REQUEST ---

class BodyContentNotifier extends Notifier<String> {
  @override
  String build() => '';
  // Setter directo expose
  // state setter is protected.
  // Exposem os propiedad set.
  @override
  set state(String val) => super.state = val;
}
// Hack para compatibilidad con code que usa .state = val?
// No, Notifier no permite .state =. Debe ser un método.
// Pero ref.read(provider.notifier).state = val ?
// La propiedad 'state' de Notifier es protected.
// Debemos añadir método 'update'.

final bodyContentProvider = NotifierProvider<_BodyNotifier, String>(
  _BodyNotifier.new,
);

class _BodyNotifier extends Notifier<String> {
  @override
  String build() => '';

  @override
  set state(String value) {
    // Override? No es un override valido publico.
    super.state = value;
  }

  // Mejor metodo update
  void update(String val) => state = val;
}

// Extension para facilitar migración de .state = x
// No podemos interseptar .state.
// Tendremos que cambiar los call sites: ref.read(p.notifier).state = x -> ref.read(p.notifier).update(x)
