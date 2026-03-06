# =============================================================================
# ProGuard / R8 rules for Smart Quiz app
# These rules are applied only when isMinifyEnabled = true.
# Currently minification is DISABLED in release — these rules act as a safety
# net in case it is ever re-enabled.
# =============================================================================

# ---------------------------------------------------------------------------
# Flutter
# ---------------------------------------------------------------------------
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ---------------------------------------------------------------------------
# Firebase — all packages use reflection extensively
# ---------------------------------------------------------------------------
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }

# Firebase Firestore — keeps model fields accessible via reflection
-keep class com.google.firebase.firestore.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Firebase Storage
-keep class com.google.firebase.storage.** { *; }

# ---------------------------------------------------------------------------
# Google Sign-In / Play Services
# ---------------------------------------------------------------------------
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

# ---------------------------------------------------------------------------
# Kotlin
# ---------------------------------------------------------------------------
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings { <fields>; }
-keepclassmembers class kotlin.Metadata { public <methods>; }

# ---------------------------------------------------------------------------
# OkHttp / http Dart package (uses OkHttp on Android)
# ---------------------------------------------------------------------------
-dontwarn okhttp3.**
-dontwarn okio.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# ---------------------------------------------------------------------------
# mobile_scanner / ZXing / ML Kit barcode
# ---------------------------------------------------------------------------
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**
-keep class com.journeyapps.barcodescanner.** { *; }

# ---------------------------------------------------------------------------
# General — keep line numbers in stack traces for easier debugging
# ---------------------------------------------------------------------------
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
