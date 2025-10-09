# App Icons

The current launcher icons are minimal placeholders to allow the app to build.

## Recommended: Use flutter_launcher_icons

For production-quality app icons, use the `flutter_launcher_icons` package:

1. Add to `pubspec.yaml` dev_dependencies:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

2. Configure in `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"  # Your 1024x1024 icon
  adaptive_icon_background: "#4CAF50"     # Green background
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

3. Create your icon image (1024x1024 PNG) in `assets/icon/`

4. Run: `flutter pub run flutter_launcher_icons`

## Design Guidelines

For VanVoyage (van life trip planning app):
- **Color Theme**: Green (#4CAF50) - representing travel, nature, adventure
- **Icon Concept**: Consider a van, road, map marker, or compass
- **Style**: Modern, flat design with clear silhouette
- **Adaptive Icon**: Use green background with white/light foreground element

## Resources
- [Material Design Icon Guidelines](https://material.io/design/iconography/product-icons.html)
- [Adaptive Icons](https://developer.android.com/develop/ui/views/launch/icon_design_adaptive)
