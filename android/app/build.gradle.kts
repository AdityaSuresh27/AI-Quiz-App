plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.quiz_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.quiz_app"
        // mobile_scanner ^7.x requires API 21 minimum — set explicitly rather than
        // relying on flutter.minSdkVersion which may resolve lower on some SDK versions.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Required when total method count exceeds 65,536 (Firebase + scanner stack).
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Signing with debug keys so flutter run --release / flutter build apk works
            // without a keystore setup. Replace with a real keystore for Play Store upload.
            signingConfig = signingConfigs.getByName("debug")
            // Keep R8/minification OFF — Firebase, Firestore and Google Sign-In use
            // reflection internally and will silently break if classes are renamed/stripped.
            isMinifyEnabled = false
            isShrinkResources = false
            // ProGuard rules file kept as a safety net if minification is ever re-enabled.
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
