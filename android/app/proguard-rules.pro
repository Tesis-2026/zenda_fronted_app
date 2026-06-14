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
