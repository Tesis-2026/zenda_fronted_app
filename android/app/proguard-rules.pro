# Flutter wrapper — keep the embedding and generated plugin registrant.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase Cloud Messaging (used via reflection by the Firebase SDK).
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**

# flutter_secure_storage (Android Keystore-backed) — keep entry points.
-keep class io.flutter.plugins.flutter_secure_storage.** { *; }

# Keep annotations and signatures used for JSON/reflection at runtime.
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Flutter's PlayStoreDeferredComponentManager references legacy Play Core task
# classes even when the app does not use deferred components. Play Feature
# Delivery 2.1.0 supplies the splitinstall APIs; these task references are
# unreachable in this app, so suppress R8 missing-class warnings for release.
-dontwarn com.google.android.play.core.tasks.**
