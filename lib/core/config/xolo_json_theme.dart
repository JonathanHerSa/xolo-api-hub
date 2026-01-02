import 'package:flutter/material.dart';
import 'package:flutter_json_view/flutter_json_view.dart';

// Definimos el estilo visual del visor de JSON
final xoloJsonTheme = JsonViewTheme(
  backgroundColor: Colors.transparent, // Para que tome el fondo de la app
  defaultTextStyle: const TextStyle(fontSize: 14, fontFamily: 'Courier'),
  viewType: JsonViewType.base, // Vista colapsable clásica
  // Colores para cada tipo de dato (Estilo Monokai/Dracula)
  stringStyle: const TextStyle(
    color: Colors.greenAccent,
    fontFamily: 'Courier',
  ),
  intStyle: const TextStyle(color: Colors.orangeAccent, fontFamily: 'Courier'),
  doubleStyle: const TextStyle(
    color: Colors.orangeAccent,
    fontFamily: 'Courier',
  ),
  boolStyle: const TextStyle(
    color: Colors.purpleAccent,
    fontWeight: FontWeight.bold,
    fontFamily: 'Courier',
  ),

  // ELIMINADO: nullStyle no existe en esta versión.
  // Los nulos se verán con el defaultTextStyle.

  // Estilo de las llaves "key": "value"
  keyStyle: const TextStyle(
    color: Colors.lightBlueAccent,
    fontWeight: FontWeight.bold,
    fontFamily: 'Courier',
  ),

  // Elementos de UI
  separator: const Text(' : ', style: TextStyle(color: Colors.white30)),

  // NOTA: Si openIcon o closeIcon también te dan error, bórralos.
  // Dependiendo de la versión exacta pueden llamarse diferente o no estar en el tema.
  closeIcon: const Icon(Icons.arrow_drop_down, size: 18, color: Colors.white54),
  openIcon: const Icon(Icons.arrow_right, size: 18, color: Colors.white54),
);
