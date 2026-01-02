# Xolo API Hub

Bienvenido a **Xolo API Hub**, una herramienta esencial para desarrolladores. Funciona como un cliente API móvil similar a Postman o ApiDog, permitiendo realizar peticiones HTTP, inspeccionar respuestas y gestionar colecciones directamente desde tu dispositivo móvil.

## Estructura del Proyecto

El proyecto sigue una arquitectura limpia (Clean Architecture) dividida en capas para asegurar la escalabilidad y mantenibilidad.

```text
lib/
├── core/                   # El núcleo compartido (Config, Utils, Constantes)
│   ├── config/             # Temas, Rutas, Env Vars
│   ├── constants/          # Strings, Assets, Enums globales
│   ├── errors/             # Excepciones personalizadas (Failure classes)
│   └── utils/              # Helpers (Formatters, Validadores)
│
├── data/                   # "Infrastructure Layer" (Cómo se obtienen los datos)
│   ├── datasources/        # Fuentes de datos crudas
│   │   ├── local/          # Drift (SQLite), SharedPrefs
│   │   └── remote/         # Dio (aunque Xolo actúa como cliente, aquí va la lógica de red)
│   ├── models/             # DTOs (Data Transfer Objects). Extienden de Entities.
│   └── repositories/       # Implementación concreta de los repositorios del dominio.
│
├── domain/                 # "Business Logic Layer" (QUÉ hace la app - Puro Dart)
│   ├── entities/           # Objetos puros (XoloRequest, Collection). Sin JSON parsing aquí.
│   └── repositories/       # Interfaces (contratos abstractos). NestJS: "Services Interfaces".
│
├── presentation/           # "UI Layer" (Lo que ve el usuario)
│   ├── providers/          # Riverpod Notifiers (State Management).
│   ├── screens/            # Pantallas completas (Scaffolds).
│   └── widgets/            # Componentes reutilizables (Botones, Inputs custom).
│
└── main.dart               # Punto de entrada.
```

## Capas

### Core

Contiene código común y utilidades que pueden ser usadas por cualquier capa.

### Data

Responsable de la obtención y persistencia de datos. Aquí se decide si los datos vienen de una API remota o de una base de datos local.

### Domain

El corazón de la aplicación. Contiene las reglas de negocio y definiciones de entidades. Esta capa no debe depender de ninguna librería externa (como Flutter o paquetes de bases de datos) en la medida de lo posible.

### Presentation

Contiene todo lo relacionado con la UI y el manejo de estado visual (usando Riverpod).
