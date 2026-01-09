plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin HARUS setelah Android & Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.materku"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Application ID
        applicationId = "com.example.materku"

        // ================== PENTING ==================
        // Minimal Android SDK (WAJIB 21)
        minSdk = flutter.minSdkVersion

        // Target SDK mengikuti Flutter
        targetSdk = flutter.targetSdkVersion

        // Versioning
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Pakai debug key dulu (aman untuk development)
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
