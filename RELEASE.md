# Zenda — Build Flavors & Release Signing

The app ships in two flavors on an `env` dimension:

| Flavor | App name   | Android applicationId          | API base URL (default)         | Cleartext HTTP |
|--------|------------|--------------------------------|--------------------------------|----------------|
| `dev`  | Zenda Dev  | `com.zenda.zenda_fronted.dev`  | `http://10.0.2.2:3000/api`     | allowed        |
| `prod` | Zenda      | `com.zenda.zenda_fronted`      | `https://api.zenda.app/api`    | blocked (HTTPS only) |

Because dev and prod use different applicationIds, both can be installed on the
same device side by side.

Per-flavor build-time config (env name, API URL, demo flag) lives in
[`dart_defines/dev.json`](dart_defines/dev.json) and
[`dart_defines/prod.json`](dart_defines/prod.json) and is read in Dart through
`lib/core/config/app_config.dart` (`AppConfig.env`, `AppConfig.apiBaseUrl`,
`AppConfig.isDemo`). Edit the JSON files to point at your real backends.

## Run / build commands

```bash
# Dev (local backend, debug)
flutter run --flavor dev --dart-define-from-file=dart_defines/dev.json

# Prod (debug against prod API)
flutter run --flavor prod --dart-define-from-file=dart_defines/prod.json

# Release artifacts
flutter build appbundle --flavor prod --dart-define-from-file=dart_defines/prod.json   # Play Store (.aab)
flutter build apk       --flavor prod --dart-define-from-file=dart_defines/prod.json   # sideload (.apk)
flutter build ipa       --flavor prod --dart-define-from-file=dart_defines/prod.json   # App Store (needs macOS)
```

Demo mode (no backend) can be forced on any flavor with `--dart-define=DEMO=true`.

---

## Android release signing

Release builds are signed from `android/key.properties` (gitignored). When that
file is absent, release builds fall back to the **debug** key so local/CI smoke
builds still succeed — but Play Store uploads require the real keystore.

### 1. Generate the keystore (once)

```bash
keytool -genkey -v -keystore zenda-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias zenda
```

Store `zenda-release.jks` outside source control (here it is expected at
`android/zenda-release.jks`, which `**/*.jks` already ignores). Back it up — if
you lose it you cannot ship updates to the same Play listing.

### 2. Create `android/key.properties`

Copy [`android/key.properties.example`](android/key.properties.example) to
`android/key.properties` and fill in real values:

```properties
storeFile=../zenda-release.jks
storePassword=...
keyAlias=zenda
keyPassword=...
```

### 3. Firebase (FCM) config per flavor

The `com.google.gms.google-services` Gradle plugin needs a `google-services.json`.
Place one per flavor (downloaded from the Firebase console for each
applicationId), then they are gitignored automatically:

```
android/app/src/dev/google-services.json    # for com.zenda.zenda_fronted.dev
android/app/src/prod/google-services.json   # for com.zenda.zenda_fronted
```

A single `android/app/google-services.json` also works if it contains both
applicationIds.

---

## iOS release signing (requires macOS + Xcode)

The flavor xcconfigs already exist: [`ios/Flutter/Dev.xcconfig`](ios/Flutter/Dev.xcconfig)
and [`ios/Flutter/Prod.xcconfig`](ios/Flutter/Prod.xcconfig). `Info.plist`
reads the launcher name from `$(APP_DISPLAY_NAME)`. To finish the wiring on a Mac:

1. Open `ios/Runner.xcworkspace` in Xcode.
2. **Build configurations:** in the project (not target) settings, duplicate
   `Debug` → `Debug-dev` / `Debug-prod`, and `Release` → `Release-dev` /
   `Release-prod`. Set each `*-dev` config to use `Flutter/Dev.xcconfig` and each
   `*-prod` config to use `Flutter/Prod.xcconfig`.
3. **Bundle id:** remove the hardcoded `PRODUCT_BUNDLE_IDENTIFIER` from the
   target's build settings so the xcconfig value applies.
4. **Schemes:** create two shared schemes named exactly `dev` and `prod`, each
   mapped to its matching build configurations. Flutter selects them via
   `--flavor dev` / `--flavor prod`.
5. **Signing:** in Signing & Capabilities, set the Team and a provisioning
   profile per configuration (manual or automatic).
6. Add `GoogleService-Info.plist` per flavor for FCM.

After this, `flutter build ipa --flavor prod --dart-define-from-file=dart_defines/prod.json`
produces a signed App Store build.

---

## CI note

In CI, materialize `android/key.properties` + the `.jks` (and the
`google-services.json` files) from encrypted secrets before
`flutter build appbundle --flavor prod`. Never commit any of them.
