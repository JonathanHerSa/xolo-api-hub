import 'package:flutter_riverpod/legacy.dart';

// 1. Provider para el Método HTTP (Por defecto GET)
// Usamos StateProvider porque es un valor simple que va a cambiar desde la UI.
final selectedMethodProvider = StateProvider<String>((ref) => 'GET');

// 2. Provider para la URL
// Este guardará lo que el usuario escriba en tiempo real.
final urlQueryProvider = StateProvider<String>((ref) => '');

// 3. Lista de métodos disponibles (Constante)
final List<String> httpMethods = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'];
