# 💠 Xolo API Hub

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Release](https://img.shields.io/github/v/release/JonathanHerSa/xolo-api-hub?style=for-the-badge&color=blueviolet)](https://github.com/JonathanHerSa/xolo-api-hub/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

**Xolo** is a premium, open-source API client for mobile devices. Built for power users and developers, Xolo bridges the gap between desktop tools like Postman and the need for high-mobility testing and automation.

---

## 🚀 Key Features

### 🎨 State-of-the-Art UX

- **Real-Time Highlighting**: Instant visual feedback for `{{variables}}` and `:parameters` across all input fields.
- **Advanced Code Editor**: Dedicated support for JSON bodies, custom headers, and query parameters with full syntax coloring.
- **Dynamic Path Parameters**: Automatically detects and extracts `:param` segments from your URLs.

### 🧪 Advanced Scripting & Test Chaining

- **Pre-Request Scripts**: Automate your workflow by generating dynamic values (e.g., `{{$timestamp}}`, `{{$guid}}`, `{{$randomInt}}`) before every request.
- **Response Extraction**: Use **JSONPath** to extract specific values from responses and store them in environment variables for subsequent requests.
- **Real-Time Validation**: Test your extraction rules instantly without re-sending requests.

### 🔐 Enterprise-Grade Security

- **OAuth 2.0 Native Support**: Seamlessly handle Authorization Code flows with an embedded ephemeral local server for secure token exchange.
- **Biometric Protection**: Secure your workspace and sensitive API keys using device-native Biometrics (FaceID/Fingerprint).
- **Intelligent Auth Inheritance**: Centralize authentication at the project or folder level—endpoints inherit security settings automatically.

---

## 📸 Screenshots

<p align="center">
  <img src="https://raw.githubusercontent.com/JonathanHerSa/xolo-api-hub/main/.github/assets/mockup.png" width="400" alt="Xolo Interface Mockup">
</p>

---

## 🛠 Tech Stack & Architecture

| Layer                 | Technology                                               |
| :-------------------- | :------------------------------------------------------- |
| **Framework**         | [Flutter 3.x](https://flutter.dev)                       |
| **State Management**  | [Riverpod](https://riverpod.dev)                         |
| **Navigation**        | [go_router](https://pub.dev/packages/go_router)           |
| **Local Persistence** | [Drift](https://drift.simonbinder.eu/) (Reactive SQLite) |
| **Networking**        | [Dio](https://pub.dev/packages/dio)                      |
| **CI/CD**             | [GitHub Actions](https://github.com/features/actions)    |

### Layered Architecture

- **Core**: Router, themes, secure storage, HTTP client, logging.
- **Domain**: Repository contracts (`XoloRepository`), domain entities, and mappers separate from Drift rows.
- **Data**: Drift database, repository implementations, import/sync services.
- **Presentation**: Screens, widgets, and Riverpod providers.

Presentation code accesses persistence through `xoloRepositoryProvider`. Low-level Drift access stays in the data layer (sync/import services).

**Localization:** UI strings live in `lib/l10n/app_en.arb` and `app_es.arb`; use `AppLocalizations.of(context)!` in widgets.

---

## 📥 Getting Started (Android)

Xolo is currently in **Release Candidate (RC1)**. You can install it for free today:

1. Navigate to the **[Releases](https://github.com/JonathanHerSa/xolo-api-hub/releases)** page.
2. Download the latest `app-release.apk`.
3. Open the file on your Android device and follow the installation prompts.

**Application ID:** `dev.jonathanhersa.xolo`

---

## 🧪 Quality

CI runs on every PR and release:

- `dart format --set-exit-if-changed`
- `flutter analyze` (strict, zero issues)
- `flutter test --coverage` with a **100% minimum** coverage gate (excluding generated `*.g.dart`, Drift schema tables, and l10n files)

See [docs/quality-gate-plan.md](docs/quality-gate-plan.md) for the roadmap.

---

## 💻 Contributing

We welcome contributions from the community!

- Found a bug? [Open an issue](https://github.com/JonathanHerSa/xolo-api-hub/issues).
- Want a new feature? [Start a discussion](https://github.com/JonathanHerSa/xolo-api-hub/discussions) or submit a PR.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Developed with ❤️ by **JonathanHerSa**
