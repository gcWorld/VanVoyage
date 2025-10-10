# Map Fix Verification Checklist

Use this checklist to verify the map display fix is working correctly.

## Prerequisites
- [ ] You have a Mapbox account at https://account.mapbox.com/
- [ ] You have obtained a public access token (starts with `pk.`)
- [ ] You have obtained a secret downloads token with DOWNLOADS:READ scope (starts with `sk.`)

## Setup Steps

### 1. Configure Dart Secrets
- [ ] Copy `lib/secrets.dart.template` to `lib/secrets.dart`
- [ ] Open `lib/secrets.dart` and replace `YOUR_MAPBOX_API_KEY_HERE` with your public token
- [ ] Verify the token starts with `pk.`

### 2. Configure Android Resources
- [ ] Copy `android/app/src/main/res/values/strings.xml.template` to `strings.xml`
- [ ] Open `strings.xml` and replace `YOUR_MAPBOX_PUBLIC_TOKEN_HERE` with your public token
- [ ] Verify you used the **same public token** as in `lib/secrets.dart`
- [ ] Verify the token starts with `pk.`

### 3. Configure Downloads Token
Choose ONE of these methods:

**Option A: Environment Variable (Recommended)**
- [ ] Add to your shell profile: `export MAPBOX_DOWNLOADS_TOKEN=sk.your_secret_token`
- [ ] Source your profile or restart terminal
- [ ] Verify: `echo $MAPBOX_DOWNLOADS_TOKEN` shows your token

**Option B: Local Properties**
- [ ] Create/edit `android/local.properties`
- [ ] Add line: `MAPBOX_DOWNLOADS_TOKEN=sk.your_secret_token`
- [ ] Verify the token starts with `sk.`

### 4. Clean and Build
- [ ] Run: `flutter clean`
- [ ] Run: `flutter pub get`
- [ ] Run: `flutter run` (or build for your target platform)
- [ ] Wait for app to launch

## Verification

### Visual Checks
- [ ] App launches successfully without build errors
- [ ] Map screen opens without crashes
- [ ] Map tiles are visible (not just blank/gray area)
- [ ] Zoom buttons are functional
- [ ] GPS/location buttons are functional
- [ ] Current location card shows your coordinates
- [ ] Map responds to touch gestures (pan, zoom)

### Expected Behavior
✅ **Success**: You should see a fully rendered map with terrain/roads/labels

❌ **Failure**: If you only see zoom buttons and location info but no map tiles, check:
- [ ] Both `lib/secrets.dart` and `strings.xml` contain your public token
- [ ] Tokens start with `pk.` (not `sk.`)
- [ ] No typos in the token
- [ ] Token is valid (check on Mapbox dashboard)
- [ ] You ran `flutter clean` before building

### Build Checks
If the build fails with authentication errors:
- [ ] Verify `MAPBOX_DOWNLOADS_TOKEN` is set (environment or local.properties)
- [ ] Verify it starts with `sk.` (secret token, not public token)
- [ ] Verify it has DOWNLOADS:READ scope on Mapbox dashboard
- [ ] Try: `unset MAPBOX_DOWNLOADS_TOKEN` then set it again

## Common Issues

### Issue: Build fails with "Could not resolve dependency"
**Solution**: Downloads token not configured properly
- Check environment variable: `echo $MAPBOX_DOWNLOADS_TOKEN`
- Or check `android/local.properties` contains the token
- Ensure token starts with `sk.` and has DOWNLOADS:READ scope

### Issue: App builds but map tiles don't load
**Solution**: Public token not configured properly
- Verify `lib/secrets.dart` has your public token (starts with `pk.`)
- Verify `android/app/src/main/res/values/strings.xml` has the same token
- Run `flutter clean && flutter run`

### Issue: "Your access token is invalid"
**Solution**: Token is expired or revoked
- Visit https://account.mapbox.com/access-tokens/
- Check if token is still active
- Generate a new token if needed
- Update both `lib/secrets.dart` and `strings.xml`

## Troubleshooting Commands

```bash
# Check if files exist with tokens
grep "mapboxApiKey" lib/secrets.dart
grep "mapbox_access_token" android/app/src/main/res/values/strings.xml

# Check if downloads token is set
echo $MAPBOX_DOWNLOADS_TOKEN

# Clean build artifacts
flutter clean
rm -rf build/
rm -rf android/.gradle/

# Rebuild
flutter pub get
flutter run
```

## Success Criteria

✅ All of these should be true:
1. App builds without errors
2. Map screen displays actual map tiles
3. Map is interactive (zoom, pan work)
4. Location tracking functions properly
5. No authentication errors in logs

## Still Having Issues?

If you've followed all steps and the map still doesn't display:

1. **Check logs**: Run with `flutter run -v` and look for Mapbox-related errors
2. **Verify token format**: 
   - Public token: `pk.eyJ1Ijoiam9...` (can be ~200 characters)
   - Secret token: `sk.eyJ1Ijoiam9...` (can be ~200 characters)
3. **Test token**: Use `curl` to test your public token:
   ```bash
   curl "https://api.mapbox.com/v4/mapbox.mapbox-streets-v8/0/0/0.mvt?access_token=YOUR_PUBLIC_TOKEN"
   ```
   Should return tile data, not an error
4. **Review documentation**: See [MAPBOX_SETUP.md](MAPBOX_SETUP.md) for detailed setup guide
5. **Check Mapbox status**: Visit https://status.mapbox.com/ to ensure services are operational

## CI/CD Verification

If you're verifying in a CI/CD environment:
- [ ] Repository secret `MAPBOX_TOKEN` is set (public token)
- [ ] Repository secret `MAPBOX_DOWNLOADS_TOKEN` is set (secret token)
- [ ] Workflow generates `lib/secrets.dart` during build
- [ ] Workflow generates `strings.xml` during build
- [ ] Build completes successfully
- [ ] APK/IPA artifact is created

---

**Need Help?** See [MAPBOX_SETUP.md](MAPBOX_SETUP.md) for setup instructions or [MAP_FIX_SUMMARY.md](MAP_FIX_SUMMARY.md) for technical details.
