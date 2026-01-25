import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/key_value_pair.dart';

/// Modelo inmutable del estado de input de un Request
class RequestSession {
  final String id;
  final String method;
  final String url;
  final List<KeyValuePair> headers;
  final List<KeyValuePair> params;
  final String body;
  final String name;

  RequestSession({
    required this.id,
    this.method = 'GET',
    this.url = '',
    required this.headers,
    required this.params,
    this.body = '',
    this.name = 'New Request',
  });

  RequestSession copyWith({
    String? id,
    String? method,
    String? url,
    List<KeyValuePair>? headers,
    List<KeyValuePair>? params,
    String? body,
    String? name,
  }) {
    return RequestSession(
      id: id ?? this.id,
      method: method ?? this.method,
      url: url ?? this.url,
      headers: headers ?? this.headers,
      params: params ?? this.params,
      body: body ?? this.body,
      name: name ?? this.name,
    );
  }
}

// --- Custom Controller (Manual State Management) ---
// Mimics StateNotifier but uses pure Dart StreamController
class RequestSessionController {
  final String id;
  final StreamController<RequestSession> _controller =
      StreamController<RequestSession>.broadcast();
  late RequestSession _state;

  RequestSessionController(this.id) {
    _state = RequestSession(
      id: id,
      headers: [KeyValuePair()],
      params: [KeyValuePair()],
    );
    // Emit initial state? StreamProvider might need it or we rely on 'state' getter logic but StreamProvider needs stream.
    // We can emit initial state slightly later or StreamProvider handles "loading".
    // For StreamProvider, it's better if we seed it.
    // But StreamController doesn't seed.
    // We can allow StreamProvider to start with initial value using `yield`.
    // Actually, simple StreamController is tricky with initial value for Riverpod.
    // Better: Provider exposes Controller, Consumers use Controller.stream and Controller.state.
    // But StreamProvider is cleaner for UI.
    // Pattern:
    // stream returns a stream that starts with current state.
  }

  RequestSession get state => _state;

  Stream<RequestSession> get stream async* {
    yield _state;
    yield* _controller.stream;
  }

  void _update(RequestSession newState) {
    _state = newState;
    _controller.add(newState);
  }

  void setMethod(String value) {
    _update(_state.copyWith(method: value));
  }

  void setUrl(String value) {
    _update(_state.copyWith(url: value));
  }

  void setBody(String value) {
    _update(_state.copyWith(body: value));
  }

  void setName(String value) {
    _update(_state.copyWith(name: value));
  }

  void updateHeaders(List<KeyValuePair> newHeaders) {
    _update(_state.copyWith(headers: _ensureEmptyRow(newHeaders)));
  }

  void updateParams(List<KeyValuePair> newParams) {
    _update(_state.copyWith(params: _ensureEmptyRow(newParams)));
  }

  List<KeyValuePair> _ensureEmptyRow(List<KeyValuePair> list) {
    if (list.isEmpty) return [KeyValuePair()];
    if (list.last.key.isNotEmpty || list.last.value.isNotEmpty) {
      return [...list, KeyValuePair()];
    }
    return list;
  }
}

// --- Providers ---

final _sessionControllers = <String, RequestSessionController>{};

final requestSessionControllerProvider =
    Provider.family<RequestSessionController, String>((ref, id) {
      return _sessionControllers.putIfAbsent(
        id,
        () => RequestSessionController(id),
      );
    });

// StreamProvider exposes the state as AsyncValue
final requestSessionProvider = StreamProvider.family<RequestSession, String>((
  ref,
  id,
) {
  final controller = ref.watch(requestSessionControllerProvider(id));
  return controller.stream;
});
