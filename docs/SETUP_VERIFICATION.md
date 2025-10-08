# VanVoyage Setup Verification

This document describes the Flutter project setup that has been completed and how to verify it.

## What Was Done

### 1. Project Structure ✅
Created the complete Flutter project structure following the architecture documentation:

```
VanVoyage/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── app.dart                     # App widget
│   ├── providers.dart               # Riverpod providers
│   ├── secrets.dart.template        # API key template
│   ├── core/                        # Core utilities
│   ├── domain/                      # Domain layer
│   ├── application/                 # Application layer (BLoCs)
│   ├── infrastructure/              # Infrastructure layer
│   └── presentation/                # Presentation layer (UI)
├── test/                            # Tests
├── android/                         # Android configuration
├── ios/                             # iOS configuration
└── .github/workflows/               # CI/CD pipelines
```

### 2. Dependencies Configuration ✅
Added all required dependencies to `pubspec.yaml`:

#### Core Dependencies
- **flutter_riverpod** (^2.4.9): State management provider
- **riverpod_annotation** (^2.3.3): Code generation annotations

#### Map & Location
- **mapbox_maps_flutter** (^1.1.0): Mapbox GL integration
- **geolocator** (^10.1.0): Location services
- **geocoding** (^2.1.1): Address geocoding

#### Database
- **sqflite** (^2.3.0): SQLite database
- **path** (^1.8.3): Path utilities

#### Navigation
- **go_router** (^12.1.1): Declarative routing

#### Utilities
- **uuid** (^4.2.1): UUID generation
- **intl** (^0.18.1): Internationalization
- **equatable** (^2.0.5): Value equality

#### Dev Dependencies
- **flutter_lints** (^3.0.1): Linting rules
- **riverpod_generator** (^2.3.9): Code generation
- **build_runner** (^2.4.7): Build system
- **mockito** (^5.4.4): Mocking for tests

### 3. Platform Configuration ✅

#### Android
- ✅ Gradle configuration (Kotlin support, Android SDK 21+ minSdk, 34 compileSdk/targetSdk)
- ✅ AndroidManifest.xml with required permissions
- ✅ MainActivity.kt
- ✅ Resource files and styles
- ✅ Location permissions configured

#### iOS
- ✅ Info.plist with location permissions
- ✅ Basic iOS configuration

### 4. CI/CD Pipeline ✅
Created GitHub Actions workflow (`.github/workflows/flutter-ci.yml`) that:
- Runs on push/PR to main and develop branches
- Checks code formatting
- Runs static analysis
- Executes tests
- Builds Android APK

### 5. Development Files ✅
- ✅ `.gitignore` configured for Flutter
- ✅ `analysis_options.yaml` with Flutter lints
- ✅ `CONTRIBUTING.md` with contribution guidelines
- ✅ Updated `README.md` with setup instructions
- ✅ Basic test file created

## How to Verify the Setup

### Prerequisites
Ensure you have Flutter installed:
```bash
flutter doctor
```

### Step 1: Clone and Install Dependencies
```bash
git clone https://github.com/gcWorld/VanVoyage.git
cd VanVoyage
flutter pub get
```

### Step 2: Configure API Keys
```bash
cp lib/secrets.dart.template lib/secrets.dart
# Edit lib/secrets.dart and add your Mapbox API key
```

**Note**: In CI/CD, this step is automatic. The workflow uses the `MAPBOX_TOKEN` repository secret to generate `lib/secrets.dart`.

### Step 3: Verify Code Quality
```bash
# Check formatting
dart format --set-exit-if-changed .

# Run static analysis
flutter analyze

# Both should complete without errors
```

### Step 4: Run Tests
```bash
flutter test
```

Expected output:
```
00:01 +1: All tests passed!
```

### Step 5: Build for Android
```bash
flutter build apk --debug
```

Expected: APK builds successfully in `build/app/outputs/flutter-apk/`

### Step 6: Run the App
```bash
# With an Android device/emulator connected
flutter run
```

Expected: App launches and shows the VanVoyage splash screen with:
- Car icon
- "VanVoyage" title
- "Trip Planning for Van Life" subtitle

## Verification Checklist

- [ ] Flutter SDK installed and `flutter doctor` shows no critical issues
- [ ] Dependencies installed with `flutter pub get`
- [ ] API key configured in `lib/secrets.dart`
- [ ] Code formatting passes: `dart format --set-exit-if-changed .`
- [ ] Static analysis passes: `flutter analyze`
- [ ] Tests pass: `flutter test`
- [ ] App builds: `flutter build apk --debug`
- [ ] App runs and shows splash screen: `flutter run`

## Known Limitations

1. **No App Icons**: Default Flutter icon is used. Custom icons can be added later.
2. **Basic Splash Screen**: Uses a simple Flutter widget. Can be enhanced with proper splash screen package.
3. **Minimal Features**: Only basic app structure is in place. Features will be added incrementally.

## Next Steps

After verifying the setup:
1. Implement domain models (see `docs/architecture/01-domain-models.md`)
2. Set up database schema (see `docs/architecture/03-data-persistence.md`)
3. Implement BLoCs and state management (see `docs/architecture/02-state-management.md`)
4. Create UI screens (see `docs/architecture/04-ui-navigation.md`)

## Troubleshooting

### Issue: `flutter pub get` fails
**Solution**: Ensure you have a stable internet connection and Flutter SDK is up to date.

### Issue: Mapbox build errors
**Solution**: Ensure you have a valid Mapbox API key in `lib/secrets.dart`.

### Issue: Android build fails
**Solution**: 
- Ensure Android SDK is installed
- Check Java/Gradle versions
- Run `flutter clean` and try again

### Issue: Tests fail
**Solution**: 
- Ensure all dependencies are installed
- Check that no breaking changes were introduced
- Review test output for specific errors

### Issue: CI/CD builds fail due to missing Mapbox key
**Solution**: 
- Ensure the `MAPBOX_TOKEN` repository secret is set in GitHub Settings → Secrets and variables → Actions
- The secret value should be your valid Mapbox API key
- The workflow automatically creates `lib/secrets.dart` from this secret

## CI/CD Secrets Setup

For repository administrators, configure the Mapbox API key as a repository secret:

1. Go to GitHub repository **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Name: `MAPBOX_TOKEN`
4. Value: Your Mapbox API key (e.g., `pk.eyJ1...`)
5. Click **Add secret**

The CI/CD workflow will automatically use this secret to create `lib/secrets.dart` during builds.

## Support

For issues with setup, please:
1. Check the Flutter documentation: https://docs.flutter.dev
2. Review architecture docs in `docs/architecture/`
3. Open an issue on GitHub with detailed error messages
