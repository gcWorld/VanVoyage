# VanVoyage Quick Start Guide

Get up and running with VanVoyage in 5 minutes!

## Prerequisites

- Flutter SDK 3.0.0+ ([Installation Guide](https://docs.flutter.dev/get-started/install))
- Android Studio or VS Code with Flutter extensions
- A Mapbox account ([Sign up free](https://account.mapbox.com/))

## Quick Setup

### 1. Clone the Repository
```bash
git clone https://github.com/gcWorld/VanVoyage.git
cd VanVoyage
```

### 2. Install Dependencies
```bash
flutter pub get
```

This will download all required packages including:
- Riverpod for state management
- Mapbox for maps
- sqflite for local database
- And more...

### 3. Configure API Keys
```bash
# Copy the template
cp lib/secrets.dart.template lib/secrets.dart

# Edit lib/secrets.dart and add your Mapbox API key
# Get your key from: https://account.mapbox.com/
```

Your `lib/secrets.dart` should look like:
```dart
const String mapboxApiKey = 'pk.eyJ1IjoieW91cnVzZXJuYW1lIiwi...';
```

### 4. Verify Setup
```bash
# Check Flutter installation
flutter doctor

# Ensure no critical issues are reported
```

### 5. Run the App
```bash
# Connect an Android device or start an emulator
# Then run:
flutter run
```

The app should launch and display the VanVoyage splash screen! 🎉

## What You Should See

When the app launches, you'll see:
- 🚐 A car icon
- "VanVoyage" title
- "Trip Planning for Van Life" subtitle

This confirms the basic setup is working correctly.

## Next Steps

Now that your app is running:

1. **Explore the Code**
   - Check out `lib/main.dart` - the app entry point
   - Look at `lib/app.dart` - the main app widget
   - Review the directory structure in `lib/`

2. **Read the Documentation**
   - [Project Setup](docs/PROJECT_SETUP.md) - Complete setup guide
   - [Architecture Overview](docs/architecture/README.md) - System design
   - [Domain Models](docs/architecture/01-domain-models.md) - Business entities
   - [State Management](docs/architecture/02-state-management.md) - BLoC + Riverpod
   - [Data Persistence](docs/architecture/03-data-persistence.md) - SQLite database

3. **Run Tests**
   ```bash
   flutter test
   ```

4. **Check Code Quality**
   ```bash
   # Format code
   dart format .
   
   # Analyze for issues
   flutter analyze
   ```

## Troubleshooting

### App won't build?
```bash
flutter clean
flutter pub get
flutter run
```

### No devices found?
```bash
# Check connected devices
flutter devices

# Start an emulator (if you have one configured)
flutter emulators --launch <emulator_id>
```

### Dependency conflicts?
```bash
flutter pub upgrade
```

### Still stuck?
1. Check the [detailed setup guide](docs/SETUP_VERIFICATION.md)
2. Run `flutter doctor -v` and fix any issues
3. Check the [troubleshooting section](docs/PROJECT_SETUP.md#troubleshooting)
4. Open an issue on GitHub with your error message

## Development Commands

Essential commands you'll use frequently:

```bash
# Run app
flutter run

# Hot reload (press 'r' while app is running)
# Hot restart (press 'R' while app is running)

# Run tests
flutter test

# Format code
dart format .

# Analyze code
flutter analyze

# Build APK
flutter build apk

# Clean build artifacts
flutter clean
```

## Project Structure Overview

```
VanVoyage/
├── lib/
│   ├── main.dart              # Entry point
│   ├── app.dart               # App widget
│   ├── core/                  # Utilities
│   ├── domain/                # Business logic
│   ├── application/           # BLoCs
│   ├── infrastructure/        # Data & services
│   └── presentation/          # UI
├── test/                      # Tests
├── android/                   # Android config
├── ios/                       # iOS config
└── docs/                      # Documentation
```

## Learning Resources

- [Flutter Basics](https://docs.flutter.dev/get-started/codelab)
- [Riverpod Tutorial](https://riverpod.dev/docs/getting_started)
- [Mapbox Flutter Guide](https://docs.mapbox.com/android/maps/guides/)
- [BLoC Pattern](https://bloclibrary.dev/)

## Need Help?

- 📖 Read the [full documentation](docs/)
- 💬 Open a [GitHub issue](https://github.com/gcWorld/VanVoyage/issues)
- 🤝 Check the [contributing guide](CONTRIBUTING.md)

Happy coding! 🚀
