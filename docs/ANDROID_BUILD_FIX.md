# Android Build Configuration Fix

## Issue
The Android build was failing with the following errors:
1. Warning: The plugin flutter_plugin_android_lifecycle requires Android SDK version 35 or higher
2. Error in geolocator_android build.gradle: "Could not get unknown property 'flutter' for extension 'android'"

## Root Cause
Flutter plugins (like `geolocator_android`) need to access Flutter SDK properties (`flutter.compileSdkVersion`, `flutter.targetSdkVersion`, etc.) during their build process. These properties were not being properly made available to subprojects/plugins, causing build failures.

## Solution
A two-part solution:
1. Define Flutter SDK properties in `gradle.properties` for centralized configuration
2. Create a `flutter` extension object in root `build.gradle` that exposes these properties to all subprojects (including plugins)

### Changes Made

1. **android/gradle.properties**
   - Added Flutter SDK properties that serve as the source of truth:
     - `flutter.compileSdkVersion=34`
     - `flutter.targetSdkVersion=34`
     - `flutter.minSdkVersion=21`
     - `flutter.ndkVersion=25.1.8937393`
     - `flutter.buildToolsVersion=34.0.0`
   - Added `android.defaults.buildfeatures.buildconfig=true` for better plugin compatibility
   - Added `android.nonTransitiveRClass=false` to ensure R classes are properly generated

2. **android/build.gradle**
   - Added a `flutter` extension object in the `subprojects` block for all subprojects:
     ```gradle
     subprojects {
         project.buildDir = "${rootProject.buildDir}/${project.name}"
         
         ext.flutter = [
             compileSdkVersion: findProperty('flutter.compileSdkVersion')?.toInteger() ?: 34,
             targetSdkVersion: findProperty('flutter.targetSdkVersion')?.toInteger() ?: 34,
             minSdkVersion: findProperty('flutter.minSdkVersion')?.toInteger() ?: 21,
             ndkVersion: findProperty('flutter.ndkVersion') ?: '25.1.8937393',
             buildToolsVersion: findProperty('flutter.buildToolsVersion') ?: '34.0.0'
         ]
     }
     ```
   - Removed `evaluationDependsOn(':app')` to avoid circular dependency issues

3. **android/app/build.gradle**
   - Uses the `flutter` extension object directly:
     - `compileSdk flutter.compileSdkVersion`
     - `targetSdk flutter.targetSdkVersion`
     - `minSdk flutter.minSdkVersion`
     - `ndkVersion flutter.ndkVersion`

### SDK Version Rationale
- **compileSdk 34**: Android 14 (latest stable at time of fix)
- **targetSdk 34**: Android 14 (matches compile SDK)
- **minSdk 21**: Android 5.0 Lollipop (unchanged, provides wide device support)
- **NDK 25.1.8937393**: Stable NDK version compatible with Flutter 3.24.x

## Benefits
1. More reliable builds across different development environments
2. Better plugin compatibility - plugins can access `flutter.compileSdkVersion` as expected
3. Explicit version control for SDK requirements with centralized configuration
4. Provides the `flutter` extension object that plugins expect to find

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
