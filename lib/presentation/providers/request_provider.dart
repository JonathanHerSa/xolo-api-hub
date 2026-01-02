import 'package:flutter_riverpod/legacy.dart';
import 'package:dio/dio.dart';

// --- 1. EL ESTADO (La foto del momento) ---
class RequestState {
  final bool isLoading;
  final dynamic data; // El cuerpo de la respuesta (JSON o String)
  final int? statusCode; // 200, 404, 500...
  final String? error; // Mensaje de error legible
  final int? durationMs; // Cuánto tardó el request

  RequestState({
    this.isLoading = false,
    this.data,
    this.statusCode,
    this.error,
    this.durationMs,
  });

  // Helper para copiar el estado y cambiar solo lo necesario
  RequestState copyWith({
    bool? isLoading,
    dynamic data,
    int? statusCode,
    String? error,
    int? durationMs,
  }) {
    return RequestState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      statusCode: statusCode ?? this.statusCode,
      error: error ?? this.error,
      durationMs: durationMs ?? this.durationMs,
    );
  }
}

// --- 2. EL NOTIFIER (La Lógica de Negocio) ---
class RequestNotifier extends StateNotifier<RequestState> {
  // OJO: En la fase de Infraestructura moveremos Dio a una capa 'Data',
  // pero para el MVP está bien instanciarlo aquí.
  final Dio _dio = Dio();

  RequestNotifier() : super(RequestState());

  Future<void> fetchData({required String method, required String url}) async {
    // 1. Validaciones básicas
    if (url.trim().isEmpty) {
      state = state.copyWith(error: 'La URL no puede estar vacía, compa.');
      return;
    }

    // 2. Estado de "Cargando" (Reseteamos error y data previa)
    state = RequestState(isLoading: true);

    final stopwatch = Stopwatch()..start();

    try {
      // 3. El Disparo
      final response = await _dio.request(
        url,
        options: Options(
          method: method,
          responseType: ResponseType.json, // Intentamos parsear JSON
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      stopwatch.stop();

      // 4. Éxito (200-299)
      state = RequestState(
        isLoading: false,
        data: response.data, // Dio ya decodifica el JSON aquí
        statusCode: response.statusCode,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } on DioException catch (e) {
      stopwatch.stop();
      // 5. Manejo de Errores HTTP controlados (404, 500, Timeouts)

      String errorMsg = 'Error desconocido';
      dynamic errorData;

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMsg = 'Tiempo de conexión agotado.';
          break;
        case DioExceptionType.badResponse:
          errorMsg =
              'El servidor respondió con error: ${e.response?.statusCode}';
          errorData = e.response?.data; // A veces el error trae JSON útil
          break;
        default:
          errorMsg = e.message ?? 'Error de red';
      }

      state = RequestState(
        isLoading: false,
        error: errorMsg,
        statusCode: e.response?.statusCode,
        data: errorData, // Mostramos la data del error si existe
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      // 6. Errores de Dart (Parseo, lógica, etc)
      state = RequestState(isLoading: false, error: e.toString());
    }
  }
}

// --- 3. EL PROVIDER GLOBAL ---
final requestProvider = StateNotifierProvider<RequestNotifier, RequestState>((
  ref,
) {
  return RequestNotifier();
});
