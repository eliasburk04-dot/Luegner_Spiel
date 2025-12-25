# Luegner Spiel - AI Coding Instructions

## Project Overview
"Lügner Spiel" is a multiplayer social deception game built with **Flutter** and **Firebase Realtime Database**.
It recently added a "Stirnraten" (Heads Up) mode.

## Architecture & Patterns

### State Management
- Uses **Provider** for state management.
- Key Service: `GameService` (`lib/services/game_service.dart`) handles all game logic and Firebase interaction.
- Access state in UI via `context.read<GameService>()` (actions) or `context.watch<GameService>()` (rebuilds).

### Directory Structure
- `lib/services/`: Business logic and Firebase calls.
- `lib/screens/`: UI Screens (Navigation via `Navigator.push`).
- `lib/models/`: Data models (`Game`, `Player`, `Room`).
- `lib/data/`: Static content (`questions.dart`, `words.dart`).
- `lib/widgets/`: Reusable UI components.

### Firebase Integration
- Uses `firebase_database` for real-time updates.
- Configuration in `lib/firebase_options.dart`.
- Data structure: Rooms contain players and game state.

### Stirnraten Game Mode
- Located in `lib/screens/stirnraten_screen.dart`.
- Uses `sensors_plus` for accelerometer input (tilt to answer).
- **Critical**: Always maintain the fallback touch controls (Left/Right tap) for devices without sensors (e.g., Desktop/Simulator).
- Word data in `lib/data/words.dart`.

## Development Workflow

### Running the App
- **Command**: `flutter run`
- **Platform**: Supports Android, iOS, Web, Windows.
- **Note**: When running on Windows/Simulator, sensor features (Stirnraten) use touch fallbacks.

### Common Tasks
- **Adding Dependencies**: Use `flutter pub add <package>`.
- **Assets**: Register new assets in `pubspec.yaml` under `flutter: assets:`.

## Coding Conventions
- **UI**: Use `AppTheme` (`lib/utils/theme.dart`) for colors and styles.
- **Async**: Handle `Future`s gracefully in UI (loading states).
- **Imports**: Prefer relative imports for files within `lib/`.
- **Localization**: Currently hardcoded German strings.

## Known Issues / Gotchas
- **Sensors**: `sensors_plus` does not support Windows Desktop. Always wrap sensor code in platform checks or try-catch blocks, or use the implemented fallback logic.
