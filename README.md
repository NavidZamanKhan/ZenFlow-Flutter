# ZenFlow Flutter

A cross-platform mobile application for the ZenFlow productivity and workspace ecosystem, built with Flutter and BLoC architecture.

## Overview

ZenFlow provides a calm, unified productivity workspace designed to organize tasks, track expenses, and manage schedules. The Flutter application delivers the full web platform experience with native performance, fluid micro-interactions, and a custom design system.

## Key Features

- Universal Design System: Dynamic light and dark mode switching with four curated accent palettes (ZenFlow Blue, Soft Teal, Violet, Coral).
- Modular BLoC Architecture: Decoupled, predictable state management with flutter_bloc across all features.
- Complete Authentication Suite:
  - Native Google OAuth 2.0 integration with Django JWT token exchange.
  - Email and password registration with live 6-digit email OTP verification.
  - Secure encrypted token persistence with automatic session restoration.
  - AuthGate root controller ensuring protected workspace routing.
- Reusable UI Primitives: Theme-aware cards, segmented controls, text inputs, badges, and icon buttons.

## Project Structure

```text
lib/
├── core/
│   ├── constants/       # API endpoints and application constants
│   ├── network/         # Dio HTTP client and request interceptors
│   ├── services/        # Third-party integrations (Google Sign-In)
│   ├── storage/         # Encrypted token and credential storage
│   ├── theme/           # Color palettes, typography scale, and ThemeBloc
│   └── widgets/         # Reusable core UI components
└── features/
    ├── auth/            # Auth models, repositories, BLoC, widgets, and views
    └── showcase/        # Design system and component preview views
```

## Technology Stack

- Framework: Flutter 3.47+ / Dart 3.13+
- State Management: flutter_bloc, equatable
- Network & API: dio
- Secure Storage: flutter_secure_storage
- Authentication: google_sign_in
- Typography & Icons: google_fonts (Plus Jakarta Sans), flutter_lucide

## Getting Started

### Prerequisites

- Flutter SDK (3.47.0 or higher)
- Xcode (for iOS Simulator and device builds)
- CocoaPods

### Setup and Running

1. Clone the repository:
   ```bash
   git clone https://github.com/NavidZamanKhan/ZenFlow-Flutter.git
   cd ZenFlow-Flutter
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run static analysis and unit tests:
   ```bash
   flutter analyze
   flutter test
   ```

4. Launch the application:
   ```bash
   flutter run
   ```

## License

Private and proprietary. All rights reserved.
