# Android Build Configuration Fix

## Issue
The Android build was failing with the following errors:
1. Warning: The plugin flutter_plugin_android_lifecycle requires Android SDK version 35 or higher
2. Error in geolocator_android build.gradle: "Could not get unknown property 'flutter' for extension 'android'"

## Root Cause
Flutter plugins (like `geolocator_android`) need to access Flutter SDK properties (`flutter.compileSdkVersion`, `flutter.targetSdkVersion`, etc.) during their build process. These properties were not being properly made available to subprojects/plugins, causing build failures.

## Solution
Define Flutter SDK properties in `gradle.properties` so they are accessible to all projects and subprojects (including plugins), then reference them in the app's `build.gradle`.

### Changes Made

1. **android/gradle.properties**
   - Added Flutter SDK properties that plugins can access:
     - `flutter.compileSdkVersion=34`
     - `flutter.targetSdkVersion=34`
     - `flutter.minSdkVersion=21`
     - `flutter.ndkVersion=25.1.8937393`
     - `flutter.buildToolsVersion=34.0.0`
   - Added `android.defaults.buildfeatures.buildconfig=true` for better plugin compatibility
   - Added `android.nonTransitiveRClass=false` to ensure R classes are properly generated

2. **android/app/build.gradle**
   - Changed to reference properties from gradle.properties:
     - `compileSdk project.property('flutter.compileSdkVersion').toInteger()`
     - `targetSdk project.property('flutter.targetSdkVersion').toInteger()`
     - `minSdk project.property('flutter.minSdkVersion').toInteger()`
     - `ndkVersion project.property('flutter.ndkVersion')`

### SDK Version Rationale
- **compileSdk 34**: Android 14 (latest stable at time of fix)
- **targetSdk 34**: Android 14 (matches compile SDK)
- **minSdk 21**: Android 5.0 Lollipop (unchanged, provides wide device support)
- **NDK 25.1.8937393**: Stable NDK version compatible with Flutter 3.24.x

## Benefits
1. More reliable builds across different development environments
2. Better plugin compatibility, especially for location-based plugins like geolocator
3. Explicit version control for SDK requirements
4. Eliminates dependency on Flutter extension property resolution

## Compatibility
- Compatible with Flutter 3.24.x and later
- Compatible with Gradle 8.1.0
- Compatible with Android Gradle Plugin 8.1.0
- Works with all current project dependencies including geolocator, mapbox_maps_flutter, etc.

## Future Updates
When updating to newer Android SDK versions:
1. Update the Flutter SDK properties in `android/gradle.properties`
2. Update documentation in `docs/PROJECT_SETUP.md` to reflect new versions

This centralized approach ensures all plugins automatically use the same SDK versions.
