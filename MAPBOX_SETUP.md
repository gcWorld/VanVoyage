# Mapbox Setup Guide

This guide explains how to configure Mapbox for VanVoyage to display maps correctly.

## Problem: Map Not Displaying

If you see the zoom buttons and location info but no map tiles, you need to configure your Mapbox tokens properly.

## Understanding Mapbox Tokens

Mapbox requires **two different tokens**:

### 1. Public Access Token (starts with `pk.`)
- **Purpose**: Used at runtime to render map tiles
- **Where to use**: 
  - `lib/secrets.dart` - For Flutter code
  - `android/app/src/main/res/values/strings.xml` - For Android native code
- **Safety**: Can be included in client-side code (public)

### 2. Secret Downloads Token (starts with `sk.`)
- **Purpose**: Used during build to download Mapbox SDK
- **Where to use**: Environment variable or `android/local.properties`
- **Safety**: Must be kept secret, never commit to git

## Setup Steps

### Step 1: Get Your Tokens

1. Go to https://account.mapbox.com/access-tokens/
2. Sign up or log in (free tier available)
3. **Public Token**: Copy your default public token (or create a new one)
4. **Secret Token**: Click "Create a token" → Select "Secret" → Enable "DOWNLOADS:READ" scope

### Step 2: Configure Dart Code

```bash
# Copy the template
cp lib/secrets.dart.template lib/secrets.dart

# Edit lib/secrets.dart and add your PUBLIC token:
# const String mapboxApiKey = 'pk.eyJ1...your-token...';
```

### Step 3: Configure Android Resources

```bash
# Copy the template
cp android/app/src/main/res/values/strings.xml.template android/app/src/main/res/values/strings.xml

# Edit strings.xml and add your PUBLIC token:
# <string name="mapbox_access_token">pk.eyJ1...your-token...</string>
```

### Step 4: Configure Downloads Token

**Option A: Environment Variable (Recommended)**
```bash
# Add to your shell profile (~/.bashrc, ~/.zshrc, etc.)
export MAPBOX_DOWNLOADS_TOKEN=sk.ey...your-secret-token...

# Or set it for current session only
export MAPBOX_DOWNLOADS_TOKEN=sk.ey...your-secret-token...
```

**Option B: Local Properties File**
```bash
# Create/edit android/local.properties (this file is gitignored)
echo "MAPBOX_DOWNLOADS_TOKEN=sk.ey...your-secret-token..." >> android/local.properties
```

### Step 5: Verify Setup

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

The map should now display correctly!

## CI/CD Configuration

For GitHub Actions or other CI/CD systems:

1. Add `MAPBOX_TOKEN` secret with your **public token**
2. Add `MAPBOX_DOWNLOADS_TOKEN` secret with your **secret token**
3. The workflow automatically creates the necessary files during build

## Files Summary

| File | Purpose | Token Type | Committed to Git? |
|------|---------|------------|-------------------|
| `lib/secrets.dart` | Flutter runtime | Public (`pk.`) | ❌ No (.gitignored) |
| `lib/secrets.dart.template` | Template | None | ✅ Yes |
| `android/.../strings.xml` | Android runtime | Public (`pk.`) | ❌ No (.gitignored) |
| `android/.../strings.xml.template` | Template | None | ✅ Yes |
| `android/local.properties` | Build time | Secret (`sk.`) | ❌ No (.gitignored) |
| Environment variable | Build time | Secret (`sk.`) | N/A |

## Troubleshooting

### Map still not showing?

1. **Check tokens are correct**:
   - Public tokens start with `pk.`
   - Secret tokens start with `sk.`
   - Don't mix them up!

2. **Verify file contents**:
   ```bash
   # Check Dart secrets
   grep "mapboxApiKey" lib/secrets.dart
   
   # Check Android strings
   grep "mapbox_access_token" android/app/src/main/res/values/strings.xml
   ```

3. **Check token validity**:
   - Visit https://account.mapbox.com/access-tokens/
   - Ensure tokens are not expired or revoked

4. **Environment variable**:
   ```bash
   # Verify it's set
   echo $MAPBOX_DOWNLOADS_TOKEN
   ```

5. **Clean build**:
   ```bash
   flutter clean
   rm -rf build/
   flutter pub get
   flutter run
   ```

### Build fails with authentication error?

This means the **secret downloads token** is not configured correctly:
- Ensure you're using a secret token (starts with `sk.`)
- Ensure it has `DOWNLOADS:READ` scope
- Set it as environment variable or in `android/local.properties`

### Map shows but tiles don't load?

This means the **public access token** is not configured correctly:
- Ensure `lib/secrets.dart` has your public token
- Ensure `android/app/src/main/res/values/strings.xml` has the same public token
- Rebuild the app: `flutter clean && flutter run`

## Security Best Practices

✅ **DO:**
- Use environment variables for secret tokens
- Keep `lib/secrets.dart` and `strings.xml` in `.gitignore`
- Use different tokens for development and production
- Rotate tokens periodically

❌ **DON'T:**
- Commit real tokens to version control
- Share secret tokens publicly
- Use secret tokens in client-side code
- Use public tokens for downloads authentication

## Additional Resources

- [Mapbox Access Tokens Documentation](https://docs.mapbox.com/help/getting-started/access-tokens/)
- [Mapbox Flutter SDK Documentation](https://docs.mapbox.com/android/maps/guides/)
- [VanVoyage Mapbox Integration Details](MAPBOX_INTEGRATION.md)
