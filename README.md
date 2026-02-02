# Xolo API Hub 🚀

**Xolo** es un cliente API móvil de alto rendimiento diseñado para desarrolladores que necesitan potencia y movilidad. Gestiona, prueba y automatiza tus peticiones HTTP desde cualquier lugar con una interfaz premium y herramientas avanzadas.

![Xolo Mockup](https://raw.githubusercontent.com/JonathanHerSa/xolo-api-hub/main/.github/assets/mockup.png)
_(Nota: Asegúrate de subir la imagen generada a esta ruta en tu repo)_

---

## ✨ Características Principales

### 🎨 Highlighting & UX Pro

- **Resaltado Dinámico**: Detección visual de `{{variables}}` y `:parametros` en tiempo real.
- **Editor Pro**: Resaltado de sintaxis en JSON, Headers y Query Params.
- **Modo Oscuro**: Interfaz diseñada para reducir la fatiga visual.

### 🧪 Scripts & Chaining (Novedad)

- **Pre-request Scripts**: Genera variables dinámicas como `{{$timestamp}}` o `{{$guid}}` antes de enviar la petición.
- **Post-request Extraction**: Extrae datos de la respuesta usando **JSONPath** y guárdalos automáticamente para la siguiente petición.

### 🔐 Seguridad y Autenticación

- **OAuth 2.0 Nativo**: Soporte para Authorization Code Flow con servidor local dinámico.
- **Biometría**: Protege tus colecciones sensibles con FaceID o huella dactilar.
- **Herencia de Auth**: Configura la autenticación a nivel de proyecto y deja que tus endpoints la hereden automáticamente.

---

## 📥 Instalación (Android)

Xolo se distribuye de forma gratuita a través de **GitHub Releases**:

1. Ve a la pestaña de [Releases](https://github.com/JonathanHerSa/xolo-api-hub/releases).
2. Descarga el último archivo `.apk`.
3. Abre el archivo en tu dispositivo Android e instálalo.

---

## 🛠 Arquitectura Tecnológica

El proyecto está construido con **Flutter** siguiendo principios de **Clean Architecture** para garantizar robustez y escalabilidad:

- **State Management**: Flutter Riverpod.
- **Database**: Drift (SQLite) con migraciones automatizadas.
- **Networking**: Dio con interceptores avanzados.
- **CI/CD**: GitHub Actions para builds automatizados de APK.

---

## 🤝 Contribuciones

¡Xolo es un proyecto abierto! Si quieres mejorar alguna funcionalidad o reportar un bug, siéntete libre de abrir un **Issue** o enviar un **Pull Request**.

---

Desarrollado con ❤️ para la comunidad de desarrolladores.
