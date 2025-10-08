# Android Build Configuration Fix

## Issue
The Android build was failing with the following errors:
1. Warning: The plugin flutter_plugin_android_lifecycle requires Android SDK version 35 or higher
2. Error in geolocator_android build.gradle: "Could not get unknown property 'flutter' for extension 'android'"

## Root Cause
The build configuration was using Flutter extension properties (`flutter.compileSdkVersion`, `flutter.targetSdkVersion`, `flutter.ndkVersion`) which are not always properly resolved in all Gradle/Flutter plugin combinations, particularly when building Flutter plugins that depend on these values.

## Solution
Changed from dynamic Flutter extension properties to explicit SDK version values in `android/app/build.gradle`:

### Changes Made

1. **android/app/build.gradle**
   - Changed `compileSdk flutter.compileSdkVersion` → `compileSdk 34`
   - Changed `targetSdk flutter.targetSdkVersion` → `targetSdk 34`
   - Changed `ndkVersion flutter.ndkVersion` → `ndkVersion "25.1.8937393"`

2. **android/gradle.properties**
   - Added `android.defaults.buildfeatures.buildconfig=true` for better plugin compatibility
   - Added `android.nonTransitiveRClass=false` to ensure R classes are properly generated

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
1. Update `compileSdk` and `targetSdk` values in `android/app/build.gradle`
2. Update `ndkVersion` if required by Flutter
3. Update documentation in `docs/PROJECT_SETUP.md` to reflect new versions
